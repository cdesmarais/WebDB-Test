--Create Stored Proc.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcSavoredSync_GetEventsToProcess]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcSavoredSync_GetEventsToProcess]
GO

CREATE PROCEDURE [dbo].[svcSavoredSync_GetEventsToProcess]
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

declare @errormessage nvarchar(500)

if (not exists (select 1 from ValueLookup where LKey = 'VVSYNC_WATERMARK'))
begin 
	set @errormessage = 
		'Missing VVSYNC_WATERMARK from ValueLookup; please run VVSyncSetup.sql before running svcSavoredSync_GetEventsToProcess proc' 
	RAISERROR(@errormessage, 16, 1)
    return -1
end

-------------------------------------------
-- Watermark initialization
-------------------------------------------

-- Get current high water mark from VVSyncLog and ValueLookup
-- We will process resos at or above this value
DECLARE @CurrentWaterMark INT
SELECT  @CurrentWaterMark=MAX(ResLogID)
FROM		(
						-- Add 1 to the ResLogID of the most recently successfully sent message
						-- VVSyncLog contains only successfully sent messages
						SELECT	MAX(ResLogID) + 1 as ResLogID 
						FROM	dbo.VVSyncLog

						
						-- We write the max + 1 of the scanned reslog range to valuelookup 
						-- at the end any successful run.
						-- This gives a lower bound for searched range of reservation log (which is huge)
				UNION	SELECT ValueInt as ResLogID from ValueLookup where LKey = 'VVSYNC_WATERMARK' 
			) as a

-- Get next high water mark from Res Log
-- We will process resos below this value
-- Since we are doing uncommitted read; Leaving a 1 minute gap to exclude the transactions that might not have been committed yet
DECLARE @NextWaterMark INT
SELECT  @NextWaterMark=MAX(ResLogID) + 1 from ReservationLog where	ResLogID >= @CurrentWaterMark and UpdateDT < DATEADD(MINUTE, -1, GETDATE())

----------------------------------------------------------------
-- Create temp table of notifications to send to VV from ResLog
----------------------------------------------------------------

SELECT		rlog.ResID								ResID,
			rlog.ResLogID							SequenceID,
			rlog.RID								RID,
			rlog.PartySize							PartySize,
			CONVERT(NVARCHAR, rlog.ShiftDT, 120)	ReservationDateTime,
			CONVERT(NVARCHAR, rlog.UpdateDT, 120)	UpdateDate,
			COALESCE(resto.RName, '')				RestaurantName,
			
			COALESCE(resto.Address1, '') 
			+ 
			CASE 
				WHEN resto.Address2 is null THEN '' 
				ELSE ' ' + resto.Address2 
			END										RestaurantAddress,							  
			
			COALESCE(resto.City, '')
			+ 
			CASE 
				WHEN resto.[State] is null THEN '' 
				ELSE ' ' + resto.[State] 
			END
			+ 
			CASE 
				WHEN resto.ZIP is null THEN '' 
				ELSE ' ' + resto.ZIP 
			END										RestaurantCity,

			COALESCE(offer.ThirdPartyOfferID, -100)	DealID,
			
			CASE
				WHEN 
				plog.RecCount = 0 and 
				rlog.RStateID NOT IN (3,8) 
				THEN 'Make'
				
				WHEN 
				plog.RecCount > 0 and 
				rlog.RStateID NOT IN (3,8) 
				THEN 'Change'
				
				WHEN rlog.RStateID IN (3,8) 
				THEN 'Cancel'
				
				ELSE 'Unknown'
			END										Operation
into		#notification
FROM		ReservationLog				rlog

inner join	RestaurantVW				resto
on			resto.RID					= rlog.RID

inner join	ReservationOffer			ro
on			ro.ResID					= rlog.ResID

inner join	RestaurantOffer				offer
on			offer.RestaurantOfferID		= ro.OfferID
and			offer.OfferClassID			= 3

CROSS APPLY (	
			-- to distinguish between Make and Change
			SELECT		COUNT(ResLogID) AS RecCount
			FROM		dbo.ReservationLog 
			WHERE		ResID = rlog.ResID
			AND			ResLogID < rlog.ResLogID 
			)  plog
		
WHERE		rlog.ResLogID				>= @CurrentWaterMark		-- at or above current watermark
and			rlog.ResLogID				<  @NextWaterMark			-- below next watermark
and			rlog.RStateID				in ( 1		-- Pending
											,3		-- Cancelled Web
											,8		-- Cancelled Restaurant
											)

---------------------------------------------------------
-- Join data with larger table: Reservation, Caller, Customer
---------------------------------------------------------
SELECT		n.ResID,
			n.SequenceID,
			r.ConfNumber							ConfirmationNumber,
			n.RID,
			n.PartySize,
			n.ReservationDateTime,
			n.UpdateDate,
			COALESCE(r.ContactPhone, '')			Phone,
			CONVERT(NVARCHAR, r.DateMade, 120)		PurchaseDate,
			COALESCE(c.FName, cc.FName, '')			DinerFirstName,
			COALESCE(c.LName, cc.LName, '')			DinerLastName,
			n.RestaurantName,
			n.RestaurantAddress,							  
			n.RestaurantCity,
			n.DealID,
			n.Operation
from		#notification				n
inner join	Reservation					r
on			r.ResID						= n.ResID
left join   Customer                    c
on          c.CustID                    = r.CustID
and         r.CallerID					is null

left join   CallerCustomer				cc
on          cc.CustID					= r.CustID   
and         r.CallerID                  is not null

ORDER BY	SequenceID


GO


GRANT EXECUTE ON [svcSavoredSync_GetEventsToProcess] TO ExecuteOnlyRole

GO
