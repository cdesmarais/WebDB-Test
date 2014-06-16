if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesListAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesListAll]
GO





CREATE PROCEDURE dbo.AdminPromosPagesListAll

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT PromoID as Promo_ID,PromoPageName as name,active,PromoPageCode 
from PromoPages
order by active desc,name


GO

GRANT EXECUTE ON [AdminPromosPagesListAll] TO ExecuteOnlyRole

GO
