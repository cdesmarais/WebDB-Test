if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_GetByIDV4]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_GetByIDV4]
GO


CREATE PROCEDURE [dbo].[Admin_Promos_Pages_GetByIDV4]
(
  @PromoID int
)
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

  SELECT 
	pp.promoid AS promo_id,
	promopagename AS name,
	promopagedesc AS description,
	promopagedescdraft AS description_draft,
	promopageimage AS image,
	promopageimagedraft AS image_draft,
	MobilePromoPageImage as MobileImage,
	MobilePromoPageDesc as MobileDescription,
	ConvertDraftLive,
	selectiondatedraft,
	imagealttag,
	pp.active,
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
	LanguageID,
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
    ppi.Imagename as StartPagePromoImg,
	RestaurantWeekPromoStatus = COALESCE (pp2pg.Active,0),
	pp.MastheadUrl

  FROM   
	PromoPages pp
	LEFT OUTER JOIN promopageexclusions
	  ON pp.promoid = promopageexclusions.promoid
	LEFT OUTER JOIN PromoPageImage ppi
		on pp.ThumbnailPromoPageImageID = ppi.PromoPageImageID
	left outer join 
		PromoPagesToPromoGroups pp2pg on
		pp2pg.PromoID = pp.promoid and 
		pp2pg.PromoGroupTypeID = 1

WHERE  pp.promoid = @PromoID

GO

GRANT EXECUTE ON [dbo].[Admin_Promos_Pages_GetByIDV4] TO ExecuteOnlyRole

GO
