if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[proc_UserSvc_GetPointsActivity_Caller]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[proc_UserSvc_GetPointsActivity_Caller]
GO

CREATE PROCEDURE dbo.proc_UserSvc_GetPointsActivity_Caller
(
    @UserID int,
    @LanguageID int,
    @StartDT datetime = '1900-01-01',
	@EndDT datetime = '9999-12-31'
)
AS
--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--** proc_UserSvc_GetPointsActivity_Cust
--** proc_UserSvc_GetPointsActivity_Caller
--**
--** These procs are part of a pair.
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @TimeZoneOffset int

select @TimeZoneOffset = tz._offsetMI 
from TimezoneVW tz
inner join ValueLookup v
on v.LType = 'DBSERVER'
and v.LKey = 'TimezoneTZID'
and v.ValueInt = tz.TZID

 --****************************
 --** Retrieve All point activity (customers)
 --** and past pending
 --****************************
 select DATEADD(MI, -@TimeZoneOffset, AdjustmentDate) as ActivityDate,
   'Adjustment' as ActivityType,
   isNull(parl.ExplanationLocal, par.Explanation) as ActivityDesc,
   AdjustmentAmount as ActivityValue
 from PointsAdjustment
 inner join PointsAdjustmentReason par
   on par.AdjReasonID = PointsAdjustment.AdjReasonID
 left outer join PointsAdjustmentReasonLocal parl
   on parl.AdjReasonID = par.AdjReasonID
   and parl.LanguageID = @LanguageID
 where PointsAdjustment.CallerID = @UserID
  and AdjustmentDate between @StartDT and @EndDT
  and PointsAdjustment.AdjReasonID <> 8 -- Do not show charity adjustments; should be shown as donations
union all
 (select DATEADD(MI, -@TimeZoneOffset, RedemptionDate) as ActivityDate,
   'Redemption' as ActivityType,
   g.GiftName as ActivityDesc,
   PointsRedeemed as ActivityValue
 from GiftRedemption
 inner join Gift g
   on g.GiftID = GiftRedemption.GiftID
 left outer join GiftLocal gl
   on gl.GiftID = g.GiftID
   and gl.LanguageID = @LanguageID
 where GiftRedemption.CallerID = @UserID
  and RedemptionDate between @StartDT and @EndDT
  and PointsRedeemed > 0
 )
 union all
 (select DATEADD(MI, -@TimeZoneOffset, RedeemDate) as ActivityDate,
  'Promo' as ActivityType,
  Promos.PromosDesc as ActivityDesc,
  PromoUse.points as ActivityValue
 from PromoUse
 inner join Promos
   on Promos.PromoID = PromoUse.PromoID
 where PromoUse.CallerID = @UserID
  -- Do not display wine.com promos; presumably this was some type of double message / bug
  and Promos.PromoTypeID <> 2
  and RedeemDate between @StartDT and @EndDT
 )
 -- For Concierges show donations
 union all
 (select DATEADD(MI, -@TimeZoneOffset, DonationDate) as ActivityDate,
   'Points Donation' as ActivityType,
   '' as ActivityDesc,
   DonationAmount as ActivityValue
 from Donations
  inner join Caller
    on Donations.CallerFrom = Caller.CallerID
  inner join Company
    on Caller.CompanyID = Company.CompanyID
  where Charity = @UserID
  -- Presumption is that charity is accounted for in the donation table and PointsAdjustment
  -- Only show the received donations
  and DonationAmount > 0
  and DATEADD(MI, -@TimeZoneOffset, DonationDate) between @StartDT and @EndDT
 )
order by ActivityDate desc

GO

GRANT EXECUTE ON [dbo].[proc_UserSvc_GetPointsActivity_Caller] TO ExecuteOnlyRole
GO