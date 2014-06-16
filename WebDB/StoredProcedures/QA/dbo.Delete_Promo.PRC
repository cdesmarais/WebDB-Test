if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Delete_Promo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Delete_Promo]
GO


CREATE PROCEDURE dbo.Delete_Promo
(
    @PromoID int
)

AS


Delete from PromoPagesToMetro where PromoID = @PromoID
Delete from PromoPagesToPromoGroups where PromoID = @PromoID
Delete from PromoPagesToRegion where PromoID = @PromoID
Delete from PromoRests where PromoID = @PromoID
Delete from PromoPages where PromoID = @PromoID



GO

GRANT EXECUTE ON [Delete_Promo] TO ExecuteOnlyRole

GO
