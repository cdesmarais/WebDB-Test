if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPages_ListForDomain]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPages_ListForDomain]
GO


CREATE PROCEDURE dbo.AdminPromosPages_ListForDomain
 (
  @Domain_ID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT 	pp.PromoID as Promo_ID,
			pp.PromoPageName as [name],
			pp.active as [active],
	pp.PromoPageCode,
	ppst.SearchTypeName
FROM 	PromoPages pp
INNER JOIN dbo.PromoPagesSearchType ppst
ON pp.PromoSearchTypeID = ppst.SearchTypeID
WHERE 	pp.SupportedDomainID = @Domain_ID
order by	[active] DESC, [name]


GO

GRANT EXECUTE ON [AdminPromosPages_ListForDomain] TO ExecuteOnlyRole

GO
