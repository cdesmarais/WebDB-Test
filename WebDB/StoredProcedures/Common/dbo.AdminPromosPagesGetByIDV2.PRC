if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesGetByIDV2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesGetByIDV2]
GO




CREATE PROCEDURE dbo.AdminPromosPagesGetByIDV2
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
	promopagedescdraft AS description_draft,
	promopageimage AS image,
	promopageimagedraft AS image_draft,
	ConvertDraftLive,
	selectiondatedraft,
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
	ChildPromoID,
    	SuppressPrice,
    ExpireMessage,
    LinkText,
    ShowOnStartPage,
    ThumbnailPromoPageImageID,
    ppi.Imagename as StartPagePromoImg
  FROM   
	PromoPages
	inner join domain ON [PromoPages].supporteddomainid = domain.domainID
	LEFT OUTER JOIN promopageexclusions
	  ON promopages.promoid = promopageexclusions.promoid
	LEFT OUTER JOIN PromoPageImage ppi
		on PromoPages.ThumbnailPromoPageImageID = ppi.PromoPageImageID
		
WHERE  promopages.promoid = @PromoID

GO

GRANT EXECUTE ON [AdminPromosPagesGetByIDV2] TO ExecuteOnlyRole

GO
