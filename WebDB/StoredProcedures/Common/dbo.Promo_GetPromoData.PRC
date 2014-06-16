GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_GetPromoData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_GetPromoData]
GO





CREATE PROCEDURE dbo.Promo_GetPromoData 
(
  @UserID int = 0,
  @CallerID int = 0,
  @SiteID int
)
AS
if @CallerID = 0
    Begin
    Select Promos.PromoID as Promo_ID,Promos.points,popuptext as popup_text
    From Promos right outer join PromoUse on Promos.PromoID = PromoUse.PromoID
    Where CustID = @UserID And SiteID = @SiteID
    End
if @CallerID > 0
    Begin
    Select Promos.PromoID as Promo_ID,Promos.points,popuptext as popup_text
    From Promos right outer join PromoUse on Promos.PromoID = PromoUse.PromoID
    Where CallerID = @CallerID And SiteID = @SiteID
    End


GO


GRANT EXECUTE ON [Promo_GetPromoData] TO ExecuteOnlyRole

GO
