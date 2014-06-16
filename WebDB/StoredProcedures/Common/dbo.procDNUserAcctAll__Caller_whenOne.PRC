if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procDNUserAcctAll__Caller_whenOne]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procDNUserAcctAll__Caller_whenOne]
GO

CREATE PROCEDURE dbo.procDNUserAcctAll__Caller_whenOne
(
    @UserID int,
    @TodayDate datetime,
	@AdminCustID int, --custid of the admin / null for regular customers
	@OriginalCustID int --original custid of the admin account if it was converted from a regular account; NULL for regular customers
)
AS
--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	procDNUserAcctAll__Caller_whenOne
--**	procDNUserAcctAll__Cust_whenOne
--**
--** These procs are part of a pair. 
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
Declare @PartnerID int, @PositionID int
	,@StartDT datetime
declare @ActiveDT datetime
declare @CreateDate as  datetime
declare @ResoStartDT as datetime

--**********************************
--** Pull the Conversion date of the user. We will use this to ensure that we don't
--** show reservation before the person registered. Or converted from Anonymous
--**********************************
Select 	@PartnerID = PartnerID, 
		@PositionID = PositionID,  -- Use PositionID for Callers; 0 for Customers
		@CreateDate = coalesce(ConvertDate,CreateDate)
from 	Caller c
left 	outer join consumertypeConvertlog ctcl 
on 	 	c.callerid = ctcl.callerID
and 	OriginalConsumerTypeID = 8
and 	ConvertDate > CreateDate
where 	c.CallerID = @UserID

Set @StartDT = '1/1/1900'
Set @ResoStartDT = dateadd(year,-1,getdate())

-- These Partners only get a 30 day history
-- "OT Concierge"
if @PartnerID = 5 or @PositionID = 2
BEGIN
	Set @StartDT = getdate() - 30
END



	--** Retrive the date the account went active
	--** The earlies of the Registration promo use or the conversion date; if not available then the create date
	select @ActiveDT =  isnull(min(convertDT), min(createdate))
	from caller c 
	left outer join 
	(

		select callerid, convertdate convertDT
		from ConsumerTypeConvertLog cl
		where originalConsumerTypeID = 8 -- Anon conversion
		and custid is null
	union all
		select callerid, redeemdate convertDT
		from promouse pu
		where promoid = 1 --Registration Promo
		and custid is null
	) cd on c.callerid = cd.callerid
	where c.callerid = @UserID
	group by c.callerid 

	-- Set the earliest allowed date to the ActiveDT
	-- only if we are looking back that far
	if (@ActiveDT > @StartDT) set @StartDT = @ActiveDT

--****************************
--** Retrieve All point activiity (callers)
--** and past pending
--****************************
	(select	AdjustmentDate as ActivityDate,
			'Adjustment' as ActivityType,
			PointsAdjustmentReasonVW.Explanation as ActivityDesc,
			AdjustmentAmount as ActivityValue,
			@AdminCustID as AdminCustID, --custid of the admin / null for regular customers
			@OriginalCustID as OriginalCustID, --original custid of the admin account if it was converted from a regular account; NULL for regular customers
			0 as ResoCustID, --CustID on the reservation -- zero since this is not a reso
			'' as EventID,
			'' as ID,		
			'' as Notes,
			'' as Incentive_ID,
			0 as IsRestReferred,
			0 as IsFavorite
			,'' as Language
			,'' AS PrimaryLanguage
			,'' as Domain
			,'' as ReservationState
	from PointsAdjustment 
	inner join	PointsAdjustmentReasonVW
			on	PointsAdjustmentReasonVW.AdjReasonID = PointsAdjustment.AdjReasonID
	where	PointsAdjustment.CallerID = @UserID
		and AdjustmentDate >= @StartDT 
		-- Only show charity adjustments that are negative (all other adjustments dispalyed)
		-- Presumption is that charity is accounted for in the donnation table and PointsAdjustment
		and (PointsAdjustment.AdjReasonID <> 8 
				or AdjustmentAmount < 0)
	) 
	union all
	(select RedemptionDate as ActivityDate,
			'Redemption' as ActivityType,
			g.GiftName as ActivityDesc,
			PointsRedeemed as ActivityValue,
			@AdminCustID as AdminCustID, --custid of the admin / null for regular customers
			@OriginalCustID as OriginalCustID, --original custid of the admin account if it was converted from a regular account; NULL for regular customers
			0 as ResoCustID, 
			'' as EventID,
			'' as ID,
			'' as Notes,
			'' as Incentive_ID,
			0 as IsRestReferred,
			0 as IsFavorite
			,'' as Language
			,'' AS PrimaryLanguage
			,'' as Domain
			,'' as ReservationState
	from GiftRedemption 
	inner join	GiftVW g
			on	g.GiftID = GiftRedemption.GiftID
	where GiftRedemption.CallerID = @UserID
		and RedemptionDate >= @StartDT 
		/*Added 1/17/03 (michael hsueh) for the free zagat book*/
		AND PointsRedeemed > 0
	) 
	union all
	--****************************
	--** Retrieve Reso Activity
	--** a) Past Pending Resos
	--** b) Positive Final State Resos and all concierge resose regardless of points
	--**
	--****************************
	(select ShiftDate + 2 + ResTime as ActivityDate,
		(case when RStateID in (2,5,6,7) then 'Dine'
			when RStateID = 1 then 'Pending'
			when RStateID = 4 then 'No Show'
			when RStateID = 10 then 'No Show - Excused' end) as ActivityType,
		r.RName as ActivityDesc,				
		(case when RStateID in (1,2,5,6,7) then ResPoints
			else 0 end) as ActivityValue,
		@AdminCustID as AdminCustID, --custid of the admin / null for regular customers
		@OriginalCustID as OriginalCustID, --original custid of the admin account if it was converted from a regular account; NULL for regular customers
		res.CustID as ResoCustID, --CustID on the reservation
		r.RID as EventID,
		res.ResID as ID,
		'' as Notes,
		'' as Incentive_ID,
		(case when rr.RID is not null then 1 else 0 end) as IsRestReferred,
		(case when cr.RID is not null then 1 else 0 end) as IsFavorite
		,l.LanguageCode as Language
		,pl.LanguageCode AS PrimaryLanguage
		,d.PublicSite as Domain
		,res.RStateID as ReservationState
	from Reservation res
	inner join	RestaurantAVW r
			on	r.RID = res.RID
			and	r.LanguageID = res.LanguageID
	inner join 	Language l
	on			res.LanguageID = l.LanguageID
	inner join 	Domain d
	on			r.DomainID = d.DomainID
	inner join 	Language pl
	on			d.PrimaryLanguageID= pl.LanguageID
	inner join 	timezoneVW tz 
			on	tz.tzid	= r.tzid
	left join 	CallerRestaurants cr 
			on 	res.RID = cr.RID
			and res.CallerID = cr.CallerID
	LEFT OUTER JOIN ReferrerRestaurantReservationVW rr
			on res.ResID = rr.resid and
				res.RID = rr.RID 
	left join 	PartnerWhiteLabel pwl
	       on	res.PartnerID = pwl.PartnerID
	where res.CallerID = @UserID
		-- Complete set of resos we care about
		and RStateID in (2,5,6,7,4,10, 1)
		-- Partion optimization to only look at data in the partitions that are gauranteed to contain future data
		-- the clause which follows is even more restrictive
		and			shiftdate > (@ResoStartDT - 5) 		
			-- Don't look too far back (enforce 30 day rule)
		and (ShiftDate + 2 + ResTime) >= @ResoStartDT
		and (
				--Pending resos only show if in the past
			(RStateID = 1 and Dateadd(mi, LocalToServerOffsetMi, (res.ShiftDate + 2 + res.ResTime)) <= @TodayDate)
				--Seated reso only show if positive points or made after they converted from anonymous
			or (RStateID in (2,4,5,6,7,10) 
				and (Dateadd(mi, LocalToServerOffsetMi, (res.ShiftDate + 2 + res.ResTime)) > @CreateDate)
				)
			)
		and pwl.PartnerID is null -- we want to EXCLUDE any reservations made by white label partners
	)
	union all
	(select RedeemDate as ActivityDate,
		'Promo' as ActivityType,
		Promos.PromosDesc as ActivityDesc,
		PromoUse.points as ActivityValue,
		@AdminCustID as AdminCustID, --custid of the admin / null for regular customers
		@OriginalCustID as OriginalCustID, --original custid of the admin account if it was converted from a regular account; NULL for regular customers
		0 as ResoCustID,
		'' as EventID,
		'' as ID,
		'' as Notes,
		'' as Incentive_ID,
		0 as IsRestReferred,
		0 as IsFavorite
		,'' as Language
		,'' AS PrimaryLanguage
		,'' as Domain
		,'' as ReservationState
	from	PromoUse 
	inner join	Promos
			on	Promos.PromoID = PromoUse.PromoID
	where PromoUse.CallerID = @UserID
		-- Do not display wine.com promos; presumably this was some type of double message / bug
		and Promos.PromoTypeID <> 2 --added by DH 11/11/2001
		and RedeemDate >= @StartDT
	)
	-- For Concierges show donations
	union all
	(select DonationDate as ActivityDate,
			'Points Donation' as ActivityType,
			'' as ActivityDesc,
			DonationAmount as ActivityValue,				
			@AdminCustID as AdminCustID, --custid of the admin / null for regular customers
			@OriginalCustID as OriginalCustID, --original custid of the admin account if it was converted from a regular account; NULL for regular customers
			0 as ResoCustID, 
			'' as EventID,
			'' as ID,
			CompanyName as Notes,
			'' as Incentive_ID,
			0 as IsRestReferred,
			0 as IsFavorite
			,'' as Language
			,'' AS PrimaryLanguage
			,'' as Domain
			,'' as ReservationState
	from Donations 
		inner join	Caller
				on	Donations.CallerFrom = Caller.CallerID
		inner join	Company
				on	Caller.CompanyID = Company.CompanyID			
		where Charity = @UserID 
		-- Presumption is that charity is accounted for in the donnation table and PointsAdjustment
		-- Only show the recieved donations
		and DonationAmount > 0
	) 
	order by ActivityDate desc 


GO


GRANT EXECUTE ON [procDNUserAcctAll__Caller_whenOne] TO ExecuteOnlyRole

go
