if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_Get]
GO




CREATE PROCEDURE dbo.Admin_Promos_Pages_Get
(
  @PromoID int
)
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT PromoID as Promo_ID,PromoPageName as name,PromoPageDesc as description,PromoPageImage as image,active from PromoPages where PromoID = @PromoID
GO

GRANT EXECUTE ON [Admin_Promos_Pages_Get] TO ExecuteOnlyRole

GO
