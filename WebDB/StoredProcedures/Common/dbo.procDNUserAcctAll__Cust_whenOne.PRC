if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procDNUserAcctAll__Cust_whenOne]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procDNUserAcctAll__Cust_whenOne]
GO

CREATE PROCEDURE dbo.procDNUserAcctAll__Cust_whenOne
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
		@PositionID = '0',  -- Use PositionID for Callers; 0 for Customers
		@CreateDate = coalesce(ConvertDate,CreateDate)
from 	customer c
left 	outer join consumertypeConvertlog ctcl 
on 	 	c.custid = ctcl.custid
and 	OriginalConsumerTypeID = 8
and 	ConvertDate > CreateDate
where 	c.custid = @UserID

Set @StartDT = '1/1/1900'
set @ResoStartDT = dateadd(year,-1,getdate())

-- These Partners only get a 30 day history
-- "OT Concierge"
if @PartnerID = 5 or @PositionID = 2
BEGIN
	Set @StartDT = getdate() - 30
END





	--** Retrive the date the account went active
	--** The earlies of the Registration promo use or the conversion date; if not available then the create date
	select @ActiveDT =  isnull(min(convertDT), min(createdate))
	from customer c 
	left outer join 
	(

		select custid, convertdate convertDT
		from ConsumerTypeConvertLog cl
		where originalConsumerTypeID = 8 -- Anon conversion
        and cl.custid = @UserID
		and callerid is null
	union all
		select custid, redeemdate convertDT
		from promouse pu
		where promoid = 1 --Registration Promo
        and pu.custid = @UserID 
		and callerid is null
	) cd on c.custid = cd.custid
	where c.custid = @UserID
	group by c.custid 
	
	-- Set the earliest allowed date to the ActiveDT
	-- only if we are looking back that far
	if (@ActiveDT > @StartDT) set @StartDT = @ActiveDT


	--****************************
	--** Retrieve All point activiity (customers)
	--** and past pending
	--****************************
	(select	AdjustmentDate as ActivityDate,
			'Adjustment' as ActivityType,
			PointsAdjustmentReasonVW.Explanation as ActivityDesc,
			AdjustmentAmount as ActivityValue,
			@AdminCustID as AdminCustID, --custid of the admin / null for regular customers
			@OriginalCustID as OriginalCustID, --original custid of the admin account if it was converted from a regular account; NULL for regular customers
			NULL as ResoCustID, -- placeholder for CustID on the reservation
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
	where	PointsAdjustment.CustID = @UserID
		and AdjustmentDate >= @StartDT 
		and PointsAdjustment.AdjReasonID <> 8 -- Do not show charity adjustments; should be shown as donations
	) 
	union all
	(select RedemptionDate as ActivityDate,
			'Redemption' as ActivityType,
			g.GiftName as ActivityDesc,
			PointsRedeemed as ActivityValue,
			@AdminCustID as AdminCustID, --custid of the admin / null for regular customers
			@OriginalCustID as OriginalCustID, --original custid of the admin account if it was converted from a regular account; NULL for regular customers
			NULL as ResoCustID, -- placeholder for CustID on the reservation
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
	where GiftRedemption.CustID = @UserID
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
		NULL as ResoCustID, -- placeholder for CustID on the reservation
		r.RID as EventID,
		res.ResID as ID,	
		'' as Notes,
		incentiveid as Incentive_ID,
		(case when rr.RID is not null then 1 else 0 end) as IsRestReferred,
		(case when f.RID is not null then 1 else 0 end) as IsFavorite
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
	left join 	Favorites f
			on 	res.RID = f.RID
			and res.CustID = f.CustID
	LEFT OUTER JOIN ReferrerRestaurantReservationVW rr
			on res.ResID = rr.resid and
				res.RID = rr.RID 
	left join 	PartnerWhiteLabel pwl
	       on   res.PartnerID = pwl.PartnerID 
	where res.Custid = @UserID
		-- Complete set of resos we care about
		and RStateID in (2,5,6,7,4,10,1)
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
		and   pwl.PartnerID is null -- we want to EXCLUDE any reservations made by white label partners   
	)
	union all
	(select RedeemDate as ActivityDate,
		'Promo' as ActivityType,
		Promos.PromosDesc as ActivityDesc,
		PromoUse.points as ActivityValue,
		@AdminCustID as AdminCustID, --custid of the admin / null for regular customers
		@OriginalCustID as OriginalCustID, --original custid of the admin account if it was converted from a regular account; NULL for regular customers
		NULL as ResoCustID, -- placeholder for CustID on the reservation
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
	where PromoUse.CustID = @UserID
		-- Do not display wine.com promos; presumably this was some type of double message / bug
		and Promos.PromoTypeID <> 2 --Added by DH 11/11/2001
		and RedeemDate >= @StartDT
	)
	order by ActivityDate desc 


GO


GRANT EXECUTE ON [procDNUserAcctAll__Cust_whenOne] TO ExecuteOnlyRole

GO
