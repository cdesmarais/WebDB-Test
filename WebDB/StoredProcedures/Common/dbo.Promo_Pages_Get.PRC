if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_Pages_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_Pages_Get]
GO

CREATE Procedure dbo.Promo_Pages_Get
(
  @PromoID int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT PromoID as Promo_ID
      ,PromoPageName as name
      ,PromoPageDesc as description
      ,PromoPageimage as image
      ,active
from   PromoPages
where  PromoID = @PromoID
GO

GRANT EXECUTE ON [Promo_Pages_Get] TO ExecuteOnlyRole

GO
