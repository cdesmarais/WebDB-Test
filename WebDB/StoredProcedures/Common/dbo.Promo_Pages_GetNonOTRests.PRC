GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_Pages_GetNonOTRests]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_Pages_GetNonOTRests]
GO











CREATE PROCEDURE dbo.Promo_Pages_GetNonOTRests
(
  @MetroArea int,
  @PromoID int
)
AS

Select RestaurantName as Restaurant_Name,Phone,Address,City 
from PromoNonOTRestaurants 
where MetroID = @MetroArea and PromoID = @PromoID
order by RestaurantName


GO


GRANT EXECUTE ON [Promo_Pages_GetNonOTRests] TO ExecuteOnlyRole

GO
