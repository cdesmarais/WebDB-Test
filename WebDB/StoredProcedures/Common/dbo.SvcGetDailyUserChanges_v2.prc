if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcGetDailyUserChanges_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcGetDailyUserChanges_v2]
GO


CREATE PROCEDURE dbo.SvcGetDailyUserChanges_v2
(
	@StartDateUTC datetime,
	@EndDateUTC	DATETIME,
	@MaxUpdatedUTC DATETIME out
)
as
/*
	Note that the UpdatedDate for customer/caller records are all UTC.  In order to
	capture the latest records for a given day behind snapshot, we need to adjust
	the date Midnight PT since that's when we create the day behind.

	Query users that have changed any of these fields:
	
	FName 
	LName 
	MetroAreaID 
	Email						
	SendAnnouncements 
	Active
	ConsumerType
	
	OR
	
	Any users that have had a seated reso within the date range given.
*/
SET NOCOUNT ON
set transaction isolation level read uncommitted

-- Constants
declare @FBSocialTypeID int = 1
declare @PIEAppPartnerName nvarchar(25) = 'Facebook Timeline App'
declare @DiningCheckRedemtionGiftID int = 3

-- Variables
declare @startday datetime, @endday datetime, @UTCMIDiff int
-- Range of report in server's time zone
declare @StartDateST datetime, @EndDateST datetime
-- PartnerID for Facebook Timeline App, for determining whether user is considered an "PIEAppUser"
declare @PIEAppPartnerID int

--Get the offset for the UTC comparisons
select			top 1 @UTCMIDiff = (ServerOffsetMI * -1)
from			TimezoneVW

--Compute start/end of in server's time zone
set @StartDateST = dateadd(MI,@UTCMIDiff * -1,@StartDateUTC)
set @EndDateST = dateadd(MI,@UTCMIDiff * -1,@EndDateUTC)

set @startday = dbo.fGetDatePart(@StartDateUTC)
set @endday = dbo.fGetDatePart(@EndDateUTC)

--Look up the PartnerID
select @PIEAppPartnerID = PartnerID from [Partner] where PartnerName = @PIEAppPartnerName
--If not found, log error and continue
if @PIEAppPartnerID is null
begin
	declare @message varchar(100) = 'Entry for "' + @PIEAppPartnerName + '" not found in partner table'
	--exec procLogProcedureError 1, 'SvcGetDailyUserChanges_v2', @message, 0
end

if object_id('tempdb..#cust') is not null
	drop table #cust
	
CREATE TABLE #cust
	(CustID int,
	CallerID int)

INSERT INTO #cust
SELECT		CustID,
			null as CallerID
FROM		Customer
WHERE		(CreateDate between @StartDateST and @EndDateST
OR			UpdatedUTC between @StartDateUTC and @EndDateUTC)
AND			ConsumerType IN (1,4,5)
UNION
SELECT		c.CustID,
			null as CallerID
FROM		CustomerPhone p
INNER JOIN	Customer c
ON			c.CustID = p.custid
WHERE		p.UpdatedUTC between @StartDateUTC and @EndDateUTC
AND			IsPrimary = 1
AND			c.ConsumerType IN (1,4,5)
UNION
SELECT		CustID,
			null as CallerID
FROM		PartnerAppToCustomer
WHERE		PartnerID = @PIEAppPartnerID
AND			CreateDateUtc between @StartDateUTC and @EndDateUTC
UNION
SELECT		CustID,
			null as CallerID
FROM		SocialCustomer sc
WHERE		SocialTypeID = @FBSocialTypeID
AND			CreateDate between @StartDateST and @EndDateST
UNION
SELECT		null as CustID,
			CallerID
FROM		Caller
WHERE		(CreateDate between @StartDateST and @EndDateST
OR			UpdatedUTC between @StartDateUTC and @EndDateUTC)
AND			ConsumerType IN (1,4,5)
UNION
SELECT		null as CustID,
			CallerID
FROM		CallerPhone
WHERE		UpdatedUTC between @StartDateUTC and @EndDateUTC
AND			IsPrimary = 1
UNION
SELECT		null as CustID,
			CallerID
FROM		PartnerAppToCaller
WHERE		PartnerID = @PIEAppPartnerID
AND			CreateDateUtc between @StartDateUTC and @EndDateUTC
UNION
SELECT		null as CustID,
			CallerID
FROM		SocialCaller sc
WHERE		SocialTypeID = @FBSocialTypeID
AND			CreateDate between @StartDateST and @EndDateST
UNION
SELECT		CustID,
			CallerID
FROM		GiftRedemption
WHERE		RedemptionDate between @StartDateST and @EndDateST
AND			GiftID = @DiningCheckRedemtionGiftID
UNION
SELECT		CustID,
			CallerID
FROM		UserOptIn
WHERE		UpdatedDtUTC between @StartDateUTC and @EndDateUTC
UNION 
SELECT		c.CustID,
			c.CallerID
FROM		UserOptIn u
INNER JOIN  Customer c
ON			c.CustID = u.CustID AND c.MetroAreaID = u.MetroAreaID
WHERE		(CreateDate between @StartDateST and @EndDateST
OR			UpdatedUTC between @StartDateUTC and @EndDateUTC)
AND			ConsumerType IN (8)
UNION
SELECT		c.CustID,
			NULL AS CallerID
FROM		Reservation r
INNER JOIN	Customer c
ON			r.CustID=c.CustID
WHERE		RStateID in (1,2,5,6,7)
AND			ShiftDate >= @startday 
AND			ShiftDate < @endday
AND			c.ConsumerType IN (1,4,5)
UNION
SELECT		NULL AS CustID,
			c.CallerID
FROM		Reservation r
INNER JOIN	Caller c
ON			r.CallerID=c.CallerID
WHERE		RStateID in (1,2,5,6,7)
AND			ShiftDate >= @startday 
AND			ShiftDate < @endday
AND			c.ConsumerType IN (1,4,5)
AND			RStateID in (1,2,5,6,7)

CREATE CLUSTERED INDEX cl1 ON #cust (CustID)
CREATE NONCLUSTERED INDEX ncl1 ON #cust (CallerID)

if object_id('tempdb..#custres') is not null
DROP TABLE #custres

SELECT r.CustID, ROW_NUMBER() over (partition by r.CustID order by resid desc) as RowNum, Datemade, RID, ResID, ReferrerID,ShiftDate 
INTO #custres
FROM ReservationVW r
INNER JOIN #cust c         
ON c.custid = r.custid
where                 r.CallerID is null
and                     RStateID in (2,5,6,7) 

CREATE CLUSTERED INDEX cl1 ON #custres (CustID)

if object_id('tempdb..#callerres') is not null
DROP TABLE #callerres

SELECT r.CallerID, ROW_NUMBER() over (partition by r.CallerID order by resid desc) as RowNum, Datemade, RID, ResID, ReferrerID,ShiftDate 
INTO #callerres
FROM ReservationVW r
INNER JOIN #cust c         
ON c.callerid = r.callerid
where                 r.CallerID is not null
and                     RStateID in (2,5,6,7) 

CREATE CLUSTERED INDEX cl1 ON #callerres (CallerID)

-- Max the maxes - this is our "highwater mark" return value
SET @MaxUpdatedUTC = (SELECT MAX(maxdate) FROM 
(SELECT MAX(UpdatedDtUTC) as maxdate FROM dbo.UserOptIn a INNER JOIN #cust c ON c.custid = a.custid
UNION ALL
SELECT MAX(UpdatedUTC) as maxdate FROM dbo.Customer a INNER JOIN #cust c ON c.custid = a.custid
UNION ALL
SELECT MAX(UpdatedDtUTC) as maxdate FROM dbo.UserOptIn a INNER JOIN #cust c ON c.callerid = a.callerid
UNION ALL
SELECT MAX(UpdatedUTC) as maxdate FROM dbo.Caller a INNER JOIN #cust c ON c.callerid = a.callerid) a)

IF @MaxUpdatedUTC < @StartDateUTC
	SET @MaxUpdatedUTC = @StartDateUTC  
IF @MaxUpdatedUTC > @EndDateUTC
	SET @MaxUpdatedUTC = @EndDateUTC  

select					case 
							when c.Active = 0 then 
								replace(c.Email, '_' + CAST(c.CustID as varchar) + '_isAAUser', '') 
							else c.Email
						end as Email,
						case when c.ConsumerType = 8 then null else c.FName end first_name,
						case when c.ConsumerType = 8 then null else c.LName end last_name,
						c.MetroAreaID Metro_area_id,
						case when c.ConsumerType = 8 then null else c.SendAnnouncements end OptInStatus,
						case when c.ConsumerType = 8 then null else c.Points  end Points,
						ct.ConsumerTypeTypeName UserType,
						null AdminType,
						case when c.ConsumerType = 8 then null else substring(cp.Phone,1,3) end AreaCode,
						case when c.ConsumerType = 8 then null else convert(nvarchar(10),r.Shiftdate,101) end LastSeatedResoDate,
						case when c.ConsumerType = 8 then null else r.RID end LastSeatedRID,
						case when c.ConsumerType = 8 then null else rt.RName end LastSeatedRestName,
						case when c.ConsumerType = 8 then null else r.ReferrerID end ReferrerID,
						tc.CustID UserID,
						case when c.ConsumerType = 8 then null else convert(nvarchar(10),isnull(CDate.ConvertDate,c.CreateDate),101) end RegDate,
						case when c.ConsumerType = 8 then null else convert
						(
							nvarchar(10),
							(	case when isnull(CDate.ConvertDate,c.CreateDate) > epwmc.StartDate 
								then isnull(CDate.ConvertDate,c.CreateDate) 
								else null end),
							101
						) end WelcomeEmailDate,
						(case when c.Active = 1 then 'Active' else 'Inactive' end) Status,
						case when c.ConsumerType = 8 then null else c.SendPromoEmail end SubscribeStatus,
						cast(coalesce(uo.SpotLight,1) as bit) SpotlightStatus,
						cast(coalesce(uo.Insider,1) as bit) InsiderNewsStatus,
						cast(coalesce(uo.DinersChoice,1) as bit) DinersChoiceStatus,
						cast(coalesce(uo.NewHot,1) as bit) NewHotStatus,
						cast(coalesce(uo.RestaurantWeek,1) as bit) RestaurantWeekStatus,
						cast(coalesce(uo.Promotional,1) as bit) PromotionalStatus,
						cast(coalesce(uo.Product,1) as bit) ProductStatus,
						c.PartnerID,
						case when c.ConsumerType = 8 then null else convert(nvarchar(10),sc.CreateDate,101) end SocialCreateDate,
						cast((case when patc.CreateDateUtc is not null then 1 else 0 end) as bit) PIEAppUser,
						case when c.ConsumerType = 8 then null else convert(nvarchar(10),gr.MaxRedemptionDate,101) end LastDiningCheckRedemption
						from #cust tc
						inner join Customer c
						on (tc.CustID = c.CustID and tc.CallerID is null)
						inner join ConsumerTypes ct
						on c.ConsumerType = ct.ConsumerTypeID
						left join (select CustID, Phone, PhoneCountryID, ROW_NUMBER() over (partition By CustID order by UpdatedUTC desc) Row FROM CustomerPhone WHERE IsPrimary = 1) cp
						on tc.CustID = cp.CustID AND Row=1
						left join	(	select		min(ctcl.ConvertDate) ConvertDate, ctcl.CustID 
										from		ConsumerTypeConvertLog ctcl
										inner join	#cust tc
										on			ctcl.CustID = tc.CustID
										where		ctcl.NewConsumerTypeID = 1
										and			ctcl.OriginalConsumerTypeID = 8
										and			ctcl.CallerID is null
										group by ctcl.CustID
						) CDate
						on tc.CustID = CDate.CustID
						left join #custres r
						on    r.CustID = c.CustID  and RowNum = 1
						left join RestaurantVW rt
						on r.RID = rt.RID
						left join EmailProviderWelcomeMailConfig epwmc
						on c.MetroAreaID = epwmc.MetroAreaID
						left join UserOptIn uo
						on tc.CustID = uo.CustID AND c.MetroAreaID = uo.MetroAreaID
						left join SocialCustomer sc
						on tc.CustID = sc.CustID and sc.SocialTypeID = @FBSocialTypeID
						left join PartnerAppToCustomer patc 
						on c.CustID = patc.CustID and patc.PartnerID = @PIEAppPartnerID
						left join (select				CustID, max(RedemptionDate) as MaxRedemptionDate
									from				GiftRedemption
									where				CustID IS NOT NULL
									and					RedemptionDate <= @EndDateST
									and					GiftID = @DiningCheckRedemtionGiftID
									group by			CustID) gr
						on c.CustID = gr.CustID
UNION ALL
select					c.Email,
						c.FName first_name,
						c.LName last_name,
						c.MetroAreaID Metro_area_id,
						c.SendAnnouncements OptInStatus,
						c.Points,
						ct.ConsumerTypeTypeName UserType,
						p.PositionName AdminType,
						substring(cp.Phone,1,3) AreaCode,
						convert(nvarchar(10),r.Shiftdate,101) LastSeatedResoDate,
						r.RID LastSeatedRID,
						rt.RName LastSeatedRestName,
						r.ReferrerID,
						tc.CallerID * -1 UserID,
						convert(nvarchar(10),isnull(CDate.ConvertDate,c.CreateDate),101) RegDate,
						convert
						(
							nvarchar(10),	
							(case when isnull(CDate.ConvertDate,c.CreateDate) > epwmc.StartDate then isnull(CDate.ConvertDate,c.CreateDate) else null end),
							101
						) WelcomeEmailDate,
						(case when c.CallerStatusID = 1 then 'Active' else 'Inactive' end) Status,
						c.SendPromoEmail SubscribeStatus,
						cast(coalesce(uo.SpotLight,1) as bit) SpotlightStatus,
						cast(coalesce(uo.Insider,1) as bit) InsiderNewsStatus,
						cast(coalesce(uo.DinersChoice,1) as bit) DinersChoiceStatus,		
						cast(coalesce(uo.NewHot,1) as bit) NewHotStatus,		
						cast(coalesce(uo.RestaurantWeek,1) as bit) RestaurantWeekStatus,		
						cast(coalesce(uo.Promotional,1) as bit) PromotionalStatus,
						cast(coalesce(uo.Product,1) as bit) ProductStatus,		
						c.PartnerID,		
						convert(nvarchar(10),sc.CreateDate,101) SocialCreateDate,
						cast((case when patc.CreateDateUtc is not null then 1 else 0 end) as bit) PIEAppUser,
						convert(nvarchar(10),gr.MaxRedemptionDate,101) LastDiningCheckRedemption
						from #cust tc
						inner join Caller c
						on (tc.CustID is null and tc.CallerID = c.CallerID)
						inner join ConsumerTypes ct
						on c.ConsumerType = ct.ConsumerTypeID
						inner join Position p
						on c.PositionID = p.PositionID
						left join (select CallerID, Phone, PhoneCountryID, ROW_NUMBER() over (partition By CallerID order by UpdatedUTC desc) Row FROM CallerPhone WHERE IsPrimary = 1) cp
						on tc.CallerID = cp.CallerID and Row=1
						left join	(	select		min(ctcl.ConvertDate) ConvertDate, ctcl.CallerID 
										from		ConsumerTypeConvertLog ctcl
										inner join	#Cust tcx
										on			ctcl.CallerID = tcx.CallerID
										where		ctcl.NewConsumerTypeID = 1
										and			ctcl.OriginalConsumerTypeID = 8
										and			ctcl.CallerID is null
										group by	ctcl.CallerID
						) CDate
						on tc.CallerID = CDate.CallerID
						left join #callerres r
						on    r.CallerID = c.CallerID  and RowNum = 1
						left join RestaurantVW rt
						on r.RID = rt.RID
						left join EmailProviderWelcomeMailConfig epwmc
						on c.MetroAreaID = epwmc.MetroAreaID
						left join UserOptIn uo
						on tc.CallerID = uo.CallerID AND c.MetroAreaID = uo.MetroAreaID
						left join SocialCaller sc
						on tc.CallerID = sc.CallerID and sc.SocialTypeID = @FBSocialTypeID
						left join PartnerAppToCaller patc 
						on c.CallerID = patc.CallerID and patc.PartnerID = @PIEAppPartnerID
						left join (select				CallerID, max(RedemptionDate) as MaxRedemptionDate
									from				GiftRedemption
									where				CallerID IS NOT NULL
									and					RedemptionDate <= @EndDateST
									and					GiftID = @DiningCheckRedemtionGiftID
									group by			CallerID) gr
						on c.CallerID = gr.CallerID
						where c.EMail is not null and c.EMail <> ''
						and c.PositionID <> 2
		 		
GO			

GRANT EXECUTE ON [SvcGetDailyUserChanges_v2] TO ExecuteOnlyRole
GO