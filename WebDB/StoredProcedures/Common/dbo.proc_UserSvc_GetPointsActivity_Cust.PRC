if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[proc_UserSvc_GetPointsActivity_Cust]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[proc_UserSvc_GetPointsActivity_Cust]
GO

CREATE PROCEDURE dbo.proc_UserSvc_GetPointsActivity_Cust
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
 where PointsAdjustment.CustID = @UserID
  and DATEADD(MI, -@TimeZoneOffset, AdjustmentDate) between @StartDT and @EndDT
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
 where GiftRedemption.CustID = @UserID
  and DATEADD(MI, -@TimeZoneOffset, RedemptionDate) between @StartDT and @EndDT
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
 where PromoUse.CustID = @UserID
  -- Do not display wine.com promos; presumably this was some type of double message / bug
  and Promos.PromoTypeID <> 2
  and DATEADD(MI, -@TimeZoneOffset, RedeemDate) between @StartDT and @EndDT
 )
order by ActivityDate desc

GO

GRANT EXECUTE ON [dbo].[proc_UserSvc_GetPointsActivity_Cust] TO ExecuteOnlyRole
GO
