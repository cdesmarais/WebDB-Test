if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procGetReservationsByRidDateRange_V4]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procGetReservationsByRidDateRange_V4]
GO

--
-- Gets all the reservations for the given RID and date range, regardless of ReservationState
-- Retrieves ShiftName from the input datatable

CREATE Procedure dbo.procGetReservationsByRidDateRange_V4


@RID				INT,
@StartDate			DATETIME,
@EndDate			DATETIME,
@ShiftData			OTCShiftDataSetV2 READONLY,
@StatusIDList		NVARCHAR(128)  -- list of ResoStatusIDs to include

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @StartDateOnly datetime
declare @EndDateOnly datetime

set @StartDateOnly = CONVERT(datetime,CAST(@StartDate as Date))
set @EndDateOnly = CONVERT(datetime,CAST(@EndDate as Date))

DECLARE @StatusList table (StringValues nvarchar(4000))

INSERT INTO @StatusList
SELECT * from fStringsToTab(@StatusIDList, ',') 


-- Create a temp table for just the resos of interest here
CREATE TABLE #Resos 
(
	[ResID] [int] NOT NULL,
	[ShiftID] [int] NOT NULL,
	[ShiftDate] [datetime] NOT NULL,
	[RStateID] [int] NOT NULL,
	[ReservationState] [nvarchar] (20),
	[CallerID] [int] NULL,
	[CustID] [int] NOT NULL,
	[ResTime] [datetime] NOT NULL,
	[PartySize] [int] NOT NULL,
	[ContactPhone] [varchar](24) NULL,
	[DateMade] [datetime] NOT NULL,
	[ConfNumber] [int] NULL,
	[SendReminder] [datetime] NULL,
	[ReminderSent] [bit] NOT NULL,
	[TimeSeated] [datetime] NULL,
	[SeatedSize] [int] NULL,
	[TimeCompleted] [datetime] NULL,
	[TimeArrived] [datetime] NULL,
	[RID] [int] NOT NULL,
	[CancelledDate] [datetime] NULL,
	[FirstTime] [bit] NULL,
	[Business] [bit] NULL,
	[PartnerID] [int] NULL,
	[CompanyID] [int] NULL,
	[IncentiveID] [int] NULL,
	[ResPoints] [int] NOT NULL,
	[UseDiningCheque] [bit] NULL,
	[LargeParty] [bit] NULL,
	[CreditCardID] [int] NULL,
	[CreditCardLastFour] [char](4) NULL,
	[Notes] [nvarchar](999) NULL,
	[ErbNotes] [nvarchar](255) NULL,
	[InviteMessage] [nvarchar](999) NULL,
	[LanguageID] [int] NULL,
	[ServerTimeToLocalTimeOffsetMinutes] [int] NOT NULL,
	--[ShiftName] [nvarchar] (256) NULL,
	--[ShiftTypeID] [int] NULL,
	[OfferDescription] [nvarchar] (500) NULL,
	[RedemptionDescription] [nvarchar] (500) NULL,
	[RedemptionCover] [int] NULL

)
-- Populate the temp table
INSERT INTO	#Resos
		(
		[ResID],
		[ShiftID],
		[ShiftDate],
		[RStateID],
		[ReservationState],
		[CallerID],
		[CustID],
		[ResTime],
		[PartySize],
		[ContactPhone],
		[DateMade],
		[ConfNumber],
		[SendReminder],
		[ReminderSent],
		[TimeSeated],
		[SeatedSize],
		[TimeCompleted],
		[TimeArrived],
		[RID],
		[CancelledDate],
		[FirstTime],
		[Business],
		[PartnerID],
		[CompanyID],
		[IncentiveID],
		[ResPoints],
		[UseDiningCheque],
		[LargeParty],
		[CreditCardID],
		[CreditCardLastFour],
		[Notes],
		[ErbNotes],
		[InviteMessage],
		[LanguageID],
		[ServerTimeToLocalTimeOffsetMinutes],
		--[ShiftName],
		--[ShiftTypeID],
		[OfferDescription],
		[RedemptionDescription],
		[RedemptionCover]
		)
SELECT 
		r.[ResID],
		[ShiftID],
		r.[ShiftDate],
		r.[RStateID],
		rs.RStateName,
		[CallerID],
		[CustID],
		[ResTime],
		[PartySize],
		CASE
			WHEN rest.Country = 'UK' AND LEFT(r.ContactPhone, 1) != '0' THEN		-- remove both spaces and periods from the number
					REPLACE(REPLACE((CAST(0 AS NVARCHAR(1)) + r.ContactPhone), '.', ''), ' ', '')	-- add a leading zero for UK RIDs that don't already have one TT 49388
			ELSE REPLACE(REPLACE(r.ContactPhone, '.', ''), ' ', '') 							-- not a UK RID, don't add the zero
		END,
		DATEADD(MI, tz.ServerToLocalOffsetMi, r.DateMade),			-- use Restaurant time for DateMade TT 44370
		[ConfNumber],
		[SendReminder],
		[ReminderSent],
		[TimeSeated],
		[SeatedSize],
		[TimeCompleted],
		[TimeArrived],
		r.[RID],
		[CancelledDate],
		[FirstTime],
		[Business],
		[PartnerID],
		[CompanyID],
		[IncentiveID],
		[ResPoints],
		[UseDiningCheque],
		[LargeParty],
		r.[CreditCardID],
		[CreditCardLastFour],
		CASE 
		 WHEN ov.OfferName IS NOT NULL AND  restoff.OfferClassID = 4 THEN ov.OfferName
		 WHEN ov.OfferDescription IS NOT NULL AND restoff.OfferClassID = 3 THEN ov.OfferDescription + ' Savored offer - via OpenTable.com. ' 
		 WHEN ov.OfferDescription IS NOT NULL THEN ' Offer:[' + ov.OfferDescription + ']' 
		 ELSE '' 
		END +
		CASE 
		 WHEN rr.RedemptionDescription IS NOT NULL THEN ' Redemption:[' + rr.RedemptionDescription + ']' +
			  ' RedemptionCovers:[' + CAST(rr.RedemptionCover AS NVARCHAR) + ']' 
		 ELSE '' 
		END +			
		r.ErbNotes + ' ' + r.Notes,
		[ErbNotes],
		[InviteMessage],
		r.[LanguageID],
		tz.ServerToLocalOffsetMi,
		--s.ShiftName,
		--s.ShiftTypeID,
		ov.OfferDescription,
		rr.RedemptionDescription,
		rr.RedemptionCover

FROM	Reservation r

INNER JOIN	Restaurant rest   WITH (NOLOCK)
ON			rest.RID = r.RID 
AND			rest.RestaurantType = 'A'

--INNER JOIN  fStringsToTab(@StatusIDList, ',') res 
--ON			r.RStateID = res.StringValues

INNER JOIN	TimezoneVW tz  WITH (NOLOCK)
ON			tz.TZID = rest.TZID

INNER JOIN	ReservationState rs WITH (NOLOCK)
ON			rs.RStateID = r.RStateID

--LEFT JOIN	@ShiftData s 
--ON			CAST(r.ResTime AS TIME) BETWEEN CAST(s.StartTime AS TIME) AND CAST(s.EndTime AS TIME)

LEFT JOIN	ReservationOffer ro WITH (NOLOCK)
ON			r.ResID = ro.ResID

LEFT JOIN	OfferVersion ov WITH (NOLOCK)
ON			ro.OfferID = ov.OfferID
AND			ro.VersionID = ov.VersionID

LEFT JOIN	RestaurantOffer restoff WITH (NOLOCK)
ON		    ro.OfferID = restoff.RestaurantOfferID
	
LEFT JOIN	ReservationRedemption rr WITH (NOLOCK)
ON			r.ResID = rr.ResID

WHERE	r.RID = @RID
AND		r.ShiftDate BETWEEN @StartDateOnly AND @EndDateOnly


-- UNION the results of queries for Customers and Callers
(
SELECT	r.RID,
		r.ResID AS ReservationID,
		r.RStateID AS ReservationStateID,
		r.ShiftDate, -- also return ShiftDate to help with Reservation view partitioning by calling procs
		CAST(r.ShiftDate AS DATE) AS ReservationDate,
		CAST(r.ResTime AS TIME) AS ReservationTime,
		r.PartySize,
		cu.FName AS FirstName,
		cu.LName AS LastName,
		cu.SFName AS FirstName_Phonetic,
		cu.SLName AS LastName_Phonetic,
		CASE 
			WHEN rcecu.CustID IS NOT NULL THEN cu.Email 
			ELSE ''
		END AS Email,
		--dbo.fOTConGetPhoneType(cu.CustID, NULL, r.ContactPhone)AS PhoneType,
		PhoneType = (SELECT TOP 1	 
			CASE PhoneType
				WHEN 'Cell' THEN 'Mobile'
				WHEN 'Work' THEN 'Phone'
				ELSE PhoneType
			END
            FROM			CustomerPhone cp
				INNER JOIN	PhoneType pt ON  pt.PhoneTypeID=cp.PhoneTypeID
            WHERE			CustID=cu.CustID 
                 AND		Phone=r.ContactPhone
            ORDER BY		IsPrimary Desc
        ),    
		r.ContactPhone,
		r.Notes,
		DateMade,			
		r.ConfNumber,
		r.ServerTimeToLocalTimeOffsetMinutes,
		s.ShiftName,
		s.ShiftTypeID,
		r.ReservationState,
		r.OfferDescription,
		r.RedemptionDescription,
		r.RedemptionCover,
		0 AS IsBlocked
FROM	#Resos r

--INNER JOIN	RestaurantVW rest   WITH (NOLOCK)
--ON			rest.RID = r.RID 
--AND			rest.RestaurantType = 'A'

INNER JOIN @StatusList res
ON			r.RStateID = res.StringValues
	
INNER JOIN	Customer cu   WITH (NOLOCK)
ON			cu.CustID = r.CustID

--INNER JOIN	TimezoneVW tz  WITH (NOLOCK)
--ON			tz.TZID = rest.TZID

--INNER JOIN	ReservationState rs WITH (NOLOCK)
--ON			rs.RStateID = r.RStateID
	
LEFT JOIN	RestaurantCustomerEmail rcecu   WITH (NOLOCK)
ON			rcecu.CustID = r.CustID 
AND			rcecu.RID = r.RID
	
LEFT JOIN	@ShiftData s 
ON			CAST(r.ResTime AS TIME) BETWEEN CAST(s.StartTime AS TIME) AND CAST(s.EndTime AS TIME)

--LEFT JOIN	ReservationOffer ro WITH (NOLOCK)
--ON			r.ResID = ro.ResID

--LEFT JOIN	OfferVersion ov WITH (NOLOCK)
--ON			ro.OfferID = ov.OfferID
--AND			ro.VersionID = ov.VersionID

--LEFT JOIN	RestaurantOffer restoff WITH (NOLOCK)
--ON		    ro.OfferID = restoff.RestaurantOfferID
	
--LEFT JOIN	ReservationRedemption rr WITH (NOLOCK)
--ON			r.ResID = rr.ResID
	
WHERE	CAST(r.ResTime AS TIME) BETWEEN CAST(@StartDate AS TIME) AND CAST(@EndDate AS TIME)
)
UNION ALL
(
SELECT	r.RID,
		r.ResID AS ReservationID,
		r.RStateID AS ReservationStateID,
		r.ShiftDate, -- also return ShiftDate to help with Reservation view partitioning by calling procs
		CAST(r.ShiftDate AS DATE) AS ReservationDate,
		CAST(r.ResTime AS TIME) AS ReservationTime,
		r.PartySize,
		cc.FName AS FirstName,
		cc.LName AS LastName,
		cc.SFName AS FirstName_Phonetic,
		cc.SLName AS LastName_Phonetic,
		CASE 
			WHEN rceca.CallerID IS NOT NULL THEN ca.Email 
			ELSE ''
		END AS Email,
		--dbo.fOTConGetPhoneType(ca.CallerID, NULL, r.ContactPhone)AS PhoneType,
		PhoneType = (SELECT TOP 1	
			CASE PhoneType
				WHEN 'Cell' THEN 'Mobile'
				WHEN 'Work' THEN 'Phone'
				ELSE PhoneType
			END
            FROM			CallerPhone cp
				INNER JOIN	PhoneType pt ON pt.PhoneTypeID=cp.PhoneTypeID
			WHERE			cp.CallerID=ca.CallerID 
				AND			Phone=r.ContactPhone
			ORDER BY		IsPrimary Desc
		),
		r.ContactPhone,
		r.Notes,
		r.DateMade,			
		r.ConfNumber,
		ServerTimeToLocalTimeOffsetMinutes,
		s.ShiftName,
		s.ShiftTypeID,
		r.ReservationState,
		r.OfferDescription,
		r.RedemptionDescription,
		r.RedemptionCover,
		0 AS IsBlocked
FROM	#Resos r

--INNER JOIN	RestaurantVW rest   WITH (NOLOCK)
--ON			rest.RID = r.RID 
--AND			rest.RestaurantType = 'A'

INNER JOIN @StatusList res
ON			r.RStateID = res.StringValues

INNER JOIN	CallerCustomer cc   WITH (NOLOCK)
ON			cc.CustID = r.CustID

INNER JOIN	Caller ca   WITH (NOLOCK)
ON			ca.CallerID = r.CallerID

--INNER JOIN	TimezoneVW tz  WITH (NOLOCK)
--ON			tz.TZID = rest.TZID

--INNER JOIN	ReservationState rs WITH (NOLOCK)
--ON			rs.RStateID = r.RStateID
	
LEFT JOIN	RestaurantCustomerEmail rceca   WITH (NOLOCK)
ON			rceca.CallerID = r.CallerID 
AND			rceca.RID = r.RID
	
LEFT JOIN	@ShiftData s 
ON			CAST(r.ResTime AS TIME) BETWEEN CAST(s.StartTime AS TIME) AND CAST(s.EndTime AS TIME)

--LEFT JOIN	ReservationOffer ro WITH (NOLOCK)
--ON			r.ResID = ro.ResID

--LEFT JOIN	OfferVersion ov WITH (NOLOCK)
--ON			ro.OfferID = ov.OfferID
--AND			ro.VersionID = ov.VersionID

--LEFT JOIN	RestaurantOffer restoff WITH (NOLOCK)
--ON		    ro.OfferID = restoff.RestaurantOfferID
	
--LEFT JOIN	ReservationRedemption rr WITH (NOLOCK)
--ON			r.ResID = rr.ResID
	
WHERE	CAST(r.ResTime AS TIME) BETWEEN CAST(@StartDate AS TIME) AND CAST(@EndDate AS TIME)
)

ORDER BY  r.ShiftDate ASC, ReservationTime ASC, ReservationID ASC -- Use ResoID as a tiebreaker so the next/prev proc works consistently




GO

GRANT EXECUTE ON [procGetReservationsByRidDateRange_V4] TO ExecuteOnlyRole
GO

GRANT EXECUTE ON [procGetReservationsByRidDateRange_V4] TO ConsoleExecuteRole

GO

