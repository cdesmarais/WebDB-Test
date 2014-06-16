if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePromoPagesList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePromoPagesList]
GO

CREATE PROCEDURE dbo.DNCachePromoPagesList
AS

SET NOCOUNT ON

SELECT
	pp.PromoID
	,pp.PromoPageName
	,pp.PromoPageImage
	,pp.ImageAltTag
	,pp.DescriptionTitle AS PromoPageDescBold
	,pp.PromoPageDesc
	,pp.PromoSearchTypeID
	,pp.PromoIcon
	,COALESCE(pptm.MetroID,0) AS MetroID
	,pp.IconBoldText
	,pp.IconText
	,pp.PromoPageCode
	,pp.active
	,COALESCE(pp.RefCodePage,0) AS RefCodePage
	,COALESCE(pp.RefCodeLink,0) AS RefCodeLink
	,dbo.fGetNextSelectionDate(pp.PromoID) AS SelectionDate
	,COALESCE(pp.begindate,dateadd(d,-1,getdate())) AS BeginDate
	,COALESCE(pp.enddate,dateadd(d,60,begindate)) AS EndDate
	,pp.SortOrder
	,pp.ExternalURL
	,CONVERT(CHAR(12),pp.selectiondate,101) AS SelDate_DatePart
	,pp.MetaPageTitle
	,pp.MetaDescription
	,pp.MetaKeyword
	,pptm.OnStartPage
	,pp.LinkLabel
	,pp.ChildPromoID
	,pptm.OnContent
	,pptm.NoFollow AS no_follow_link
	,COALESCE(pp.SuppressDIP,0) AS SuppressDIP
	,pp.ExpireMessage
	,pp.SuppressPrice	
	,pp.ShowOnStartPage
	,pp.LinkText
	,ppi.ImageName as ThumbnailPromoPageImageName
	,pp.MobilePromoPageImage as MobileMastheadImage
	,pp.MobilePromoPageDesc as MobileDescription
	,COALESCE(pppg.PromoGroupTypeID, 0) AS PromoGroupTypeID
	,pp.MastheadUrl
FROM dbo.PromoPages pp
LEFT OUTER JOIN dbo.PromoPagesToMetro pptm ON pp.PromoID = pptm.PromoID and MetroID in 
	(select MetroAreaID from dbo.MetroAreaVW where active = 1)
LEFT OUTER JOIN dbo.PromoPageImage ppi on pp.ThumbnailPromoPageImageID  = ppi.PromoPageImageID
LEFT OUTER JOIN dbo.PromoPagesToPromoGroups pppg on pp.PromoID = pppg.PromoID  AND pppg.Active = 1
INNER JOIN dbo.DBUserDistinctLanguageVW db on db.languageid = pp.LanguageID

ORDER BY SortOrder, PromoPageName
GO

GRANT EXECUTE ON [DNCachePromoPagesList] TO ExecuteOnlyRole
GO

