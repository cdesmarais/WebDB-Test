--Create Stored Proc.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcOfferCleanup_GetEventsToProcess]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcOfferCleanup_GetEventsToProcess]
GO

CREATE PROCEDURE [dbo].[svcOfferCleanup_GetEventsToProcess]
AS
--Since the table ReservationLog is in the critical Make/Change/Cancel transcation path using 
--uncommitted reads to avoid any potential locking issues. There is predicate in the WHERE clause
--to avoid reading uncommitted data by eleminating last 1 minute worth of records

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

declare @errormessage nvarchar(500)

if (not exists (select 1 from ValueLookup where LKey = 'OFFER_CLEANUP_WATERMARK'))
begin 
	set @errormessage = 
		'Missing OFFER_CLEANUP_WATERMARK from ValueLookup; please run OfferCleanupSetup.sql before running offer cleanup' 
	RAISERROR(@errormessage, 16, 1)
    return -1
end

-------------------------------------------
-- Watermark initialization
-------------------------------------------
DECLARE	@CurrentWaterMark INT

SELECT	@CurrentWaterMark	= ValueInt 
from	ValueLookup 
where	LKey				= 'OFFER_CLEANUP_WATERMARK' 

DECLARE @NextWaterMark INT

SELECT  @NextWaterMark		= MAX(ResLogID) 
from	ReservationLog 
where	ReslogID			> @CurrentWaterMark 
and		UpdateDT			< DATEADD(MINUTE, -1, GETDATE())

-- NOTE: @NextWaterMark could be null 
-- if no new records have arrived since last watermark that meet the update criteria

-------------------------------------------
-- Event selection
-- Collect most recent relevant events along with current reso state
-------------------------------------------
select		T.ResLogID						ResLogID,	
			r.RID							RID,		
			r.PartySize						PartySize,
			r.ShiftDate + r.ResTime + 2		ShiftDate,	
			T.OfferID						OfferID,
			T.OfferConfNumber				OfferConfNumber,
			case 
				when r.RStateID in (3,8) then 'Cancel'
				else 'Change'
			end								Operation

from
(
			-- Select most recent unprocessed reslog events for offer resos,
			-- gathering ResLogID (for watermark update), OfferID, OfferConfNumber.
			
			SELECT		max(rlog.ResLogID)			ResLogID,
						rlog.ResID					ResID,
						ro.OfferID					OfferID,
						ro.OfferConfNumber			OfferConfNumber
						
			FROM		ReservationLog				rlog

			inner join	ReservationOffer			ro
			on			ro.ResID					= rlog.ResID

			inner join	RestaurantOffer				offer
			on			offer.RestaurantOfferID		= ro.OfferID
			
			inner join	OfferClass					oc
			on			oc.OfferClassID				= offer.OfferClassID
			and			oc.IsInventoryManaged		= 1

			WHERE		rlog.ResLogID				>  @CurrentWaterMark		-- above current watermark
			and			rlog.ResLogID				<=  @NextWaterMark			-- at or below next watermark
			and			(	
						rlog.DBUser					NOT LIKE 'WebUser%'			-- non consumer-website-initiated 
						OR
						rlog.DBUser					= 'WebUserRegion'
						OR
						rlog.Host					LIKE '%CHARM%'
						)

			and			rlog.RStateID				in ( 1,3,8)					-- Pending, Cancelled Web, Cancelled Restaurant									

			group by	rlog.ResID, ro.OfferID, ro.OfferConfNumber
) as T

-- Join with reservation to get current reservation state
inner join	Reservation			r
on			r.ResID				= T.ResID
where		r.ShiftDate			> GETDATE() - 30 -- force the use of the reservation partition
order by	T.ResLogID			asc



-- optimization: if no records are found, reset the watermark here
if (@@ROWCOUNT = 0)
begin
	update	ValueLookup 
	set		ValueInt		= @NextWaterMark
	where	LKey			= 'OFFER_CLEANUP_WATERMARK'
	and		@NextWaterMark	is not null -- To deal with corner case when no new water mark fetched
end

GO

GRANT EXECUTE ON [svcOfferCleanup_GetEventsToProcess] TO ExecuteOnlyRole

GO
