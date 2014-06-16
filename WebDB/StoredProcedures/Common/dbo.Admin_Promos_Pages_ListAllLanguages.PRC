if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_ListAllLanguages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_ListAllLanguages]
GO


CREATE PROCEDURE dbo.Admin_Promos_Pages_ListAllLanguages
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT 	pp.PromoID as Promo_ID,
		pp.PromoPageName as [name],
		pp.active as [active],
		pp.PromoPageCode,
		ppst.SearchTypeName,
		pp.LanguageID
FROM 	PromoPages pp
INNER JOIN dbo.PromoPagesSearchType ppst
ON pp.PromoSearchTypeID = ppst.SearchTypeID
order by	[active] DESC, [name]


GO

GRANT EXECUTE ON [Admin_Promos_Pages_ListAllLanguages] TO ExecuteOnlyRole

GO
