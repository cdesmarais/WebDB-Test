--Create a table type.
IF NOT EXISTS (SELECT * FROM sys.types WHERE name='ResLog_RIDsToProcess_V3' AND is_table_type=1)
	CREATE TYPE dbo.ResLog_RIDsToProcess_V3 AS TABLE 
	( 
		 RID					INT				NOT NULL,
		 ContactInfo			NVARCHAR(256)	NOT NULL,
		 ProviderName			NVARCHAR(64)	NOT NULL,
		 AlertTypeID			INT				NOT NULL,		
		 AlertFrequencyTypeID	INT				NOT NULL,
		 AlertStartDT			DATETIME		NOT NULL,
		 IsEmailBased			BIT				NOT NULL,
		 LanguageID				INT				NOT NULL,
		 ShowResoPhone			BIT				NOT NULL,
		 CultureID				NVARCHAR(5)		NOT NULL,
		 FormatPhone			NVARCHAR(256)	NOT NULL,
		 FormatPhoneExt			NVARCHAR(256)	NOT NULL,
		 FormatPhoneJP10		NVARCHAR(256)	NULL,
		 FormatPhoneJPNon10		NVARCHAR(256)	NULL,
		 ShouldGetOffers		BIT
	);
GO

GRANT EXECUTE ON TYPE::dbo.ResLog_RIDsToProcess_V3 TO ExecuteOnlyRole
GO

--Create Stored Proc.

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcResLog_GetEventsToProcess_V3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcResLog_GetEventsToProcess_V3]
GO

CREATE PROCEDURE [dbo].[svcResLog_GetEventsToProcess_V3]

@RIDsToProcess	dbo.ResLog_RIDsToProcess_V3 READONLY

AS

--Since the table ReservationLog is in the critical Make/Change/Cancel transcation path using 
--uncommitted reads to avoid any potential locking issues. There is predicate in the WHERE clause
--to avoid reading uncommitted data by eleminating last 1 minute worth of records
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @MINResLogIDProcessedMsgs INT
DECLARE @MAXResLogIDYesterday INT

--Get Min ResLogID from Procesed Messages to use as Lower Bound;
-- Either process from the least of oldest failed message 
-- and the most recent success message
SELECT            @MINResLogIDProcessedMsgs=MIN(ResLogID)
FROM		(
				-- Retrieve the most recently sent message
				SELECT MAX(ResLogID) ResLogID FROM  dbo.ResLog_SentMessage
				UNION ALL
				-- Retrieve the oldest failed message that still needs to be sent
				SELECT MIN(ResLogID) ResLogID FROM  dbo.ResLog_FailedMessage where RetryCount < 5 -- Only include the events that haven't been tried 5 times
			) as a




--If the value is null then get yesterday's MAX Reslogid
IF @MINResLogIDProcessedMsgs IS NULL
 BEGIN
	SELECT		@MAXResLogIDYesterday=MAX(ResLogID)
	FROM		ReservationLog 
	WHERE		UpdateDT < CAST(GETDATE() AS DATE)
 END

--------------------------------
-- Create temp table of events that have recently occured
--------------------------------
select		rl.reslogid,
			rl.ResID,
			rl.rid,
			rl.RStateID,
			rlCount.RecCount,
			rl.CustID,
			rl.CallerID,
			rl.ShiftDT,
			rl.PartySize,
			rp.ContactInfo,
			rp.ProviderName,
			rp.AlertTypeID,
			rp.AlertFrequencyTypeID,
			rp.AlertStartDT,
			rp.IsEmailBased,
			rp.LanguageID,
			rp.ShowResoPhone,
			rp.CultureID,
			rp.FormatPhone,
			rp.FormatPhoneExt,
			rp.FormatPhoneJP10,
			rp.FormatPhoneJPNon10,
			rp.ShouldGetOffers

into		#ResLog 
FROM		dbo.ReservationLog rl

INNER JOIN	@RIDsToProcess rp
ON			rl.RID = rp.RID -- Pick only relevant RID's

CROSS APPLY (	-- Find the count of ResLogID for this Reso to distinguish between Make and Change
				SELECT		COUNT(ResLogID) AS RecCount
				FROM		dbo.ReservationLog 
				WHERE		ResID = rl.ResID
				AND			ResLogID <= rl.ResLogID
			)  rlCount

LEFT JOIN	dbo.ResLog_SentMessage s
ON			rl.ResLogID = s.ResLogID -- Exclude the events that have already been notified successfully
AND			rp.ContactInfo = s.ContactInfo

LEFT JOIN	dbo.ResLog_FailedMessage f
ON			rl.ResLogID = f.ResLogID
AND			rp.ContactInfo = f.ContactInfo
AND			f.RetryCount >= 5 -- Only Exclude the events that have been tried 5 times

WHERE		rl.ResLogID >=	ISNULL	(	--Only look at the messages that haven't been processed before
										@MINResLogIDProcessedMsgs,
										--If the value is null then use yesterday's MAX Reslogid
										@MAXResLogIDYesterday
									)

AND			rl.RStateID IN (1,3)	-- Pick only make, change and cancel done from the WebSite
AND			rl.DBUser LIKE 'webuser%'	-- This would ensure actions done from WebSite Only
AND			rl.DBUser <> 'WebUserRegion'	-- This account is used by Service
AND			s.ResLogID IS NULL
AND			f.ResLogID IS NULL
AND			rl.UpdateDT >= rp.AlertStartDT	--Only send alerts for the events happened after the Alert was subscribed to
AND			rl.UpdateDT < DATEADD(MINUTE, -1, GETDATE())	-- Since we are doing uncommitted reads; leave out Res events from
															-- the past 1 minute period as some may still be uncommitted

------------------------------
--Get Reso Events 
-- Join with larger tables
------------------------------
SELECT		rl.ResLogID,
			(
				CASE
					WHEN RecCount = 1 AND rl.RStateID = 1 THEN 'Make'
					WHEN RecCount > 1 AND rl.RStateID = 1 THEN 'Change'
					WHEN rl.RStateID = 3 THEN 'Cancel'
					ELSE 'Other'
				END 
			) EventType,
			rl.ResID,
			rl.RID,
			ContactInfo,
			rt.RName,
			rl.PartySize,
			rl.ShiftDT,
			ISNULL(c.LName, cc.LName) AS LName,
			ISNULL(c.FName, cc.FName) AS FName,
			ProviderName,
			IsEmailBased,
			AlertTypeID AS MessageType,
			AlertFrequencyTypeID AS MessageFrequencyType,
			rl.LanguageID,
			r.ContactPhone AS 'ResoPhone',
			ShowResoPhone,
			CultureID,
			FormatPhone,
			FormatPhoneExt,
			FormatPhoneJP10,
			FormatPhoneJPNon10,
			ShouldGetOffers,
			OfferDescription
			
FROM		#ResLog  rl
INNER JOIN	dbo.RestaurantVW rt
ON			rl.RID=rt.RID

INNER JOIN	dbo.TimezoneVW t
ON			rt.TZID=t.TZID

INNER JOIN	dbo.Reservation r -- for reso phone
ON			rl.ResID = r.ResID 
AND			r.ShiftDate > GETDATE()-30  

LEFT JOIN	dbo.Customer c
ON			rl.CustID = c.CustID
AND			rl.CallerID IS NULL

LEFT JOIN	dbo.CallerCustomer cc
ON			rl.CustID = cc.CustID
AND			rl.CallerID IS NOT NULL

LEFT JOIN	ReservationOffer ro 
ON			rl.ResID = ro.ResID

LEFT JOIN	OfferVersion ov
ON			ro.OfferID = ov.OfferID
AND			ro.VersionID = ov.VersionID

WHERE       t.currentLocalTime < rl.ShiftDT --Any resos in the past are stale 
ORDER BY	rl.ResLogID -- Give the set sorted so that events get processed in correct order


GO

GRANT EXECUTE ON [svcResLog_GetEventsToProcess_V3] TO ExecuteOnlyRole

GO
