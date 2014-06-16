if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_List]
GO



CREATE PROCEDURE dbo.Admin_Promos_Pages_List

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT PromoID as Promo_ID,PromoPageName as name,PromoPageDesc as description,PromoPageImage as image,active from PromoPages
order by active desc,name
GO

GRANT EXECUTE ON [Admin_Promos_Pages_List] TO ExecuteOnlyRole

GO
