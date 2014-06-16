if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesGetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesGetByID]
GO




CREATE PROCEDURE dbo.AdminPromosPagesGetByID
(
  @PromoID int
)
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

  SELECT 
	promopages.promoid AS promo_id,
	promopagename AS name,
	promopagedesc AS description,
	promopageimage AS image,
	imagealttag,
	promopages.active,
	promosearchtypeid,
	promoicon,
	iconboldtext,
	icontext,
	promopagecode,
	refcodepage,
	refcodelink,
	selectiondate,
	begindate,
	enddate,
	sortorder,
	externalurl,
	suppressdip,
	qualifyconfmessage,
	nonqualifyconfmessage,
	exclusiondate,
	promogrouping,
	eventstartdate,
	eventenddate,
	exclusionmessage,
	displaysearchboxexclusion,
	supporteddomainid,
	SiteDisplayName,
	DescriptionTitle,
	MetaPageTitle,
	MetaDescription,
	MetaKeyword,
	LinkLabel,
	ChildPromoID
  FROM   
	PromoPages
	inner join domain ON [PromoPages].supporteddomainid = domain.domainID
	LEFT OUTER JOIN promopageexclusions
	  ON promopages.promoid = promopageexclusions.promoid
WHERE  promopages.promoid = @PromoID

GO

GRANT EXECUTE ON [AdminPromosPagesGetByID] TO ExecuteOnlyRole

GO
