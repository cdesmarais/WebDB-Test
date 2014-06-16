if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromoSvcCachePromoLocalized]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].PromoSvcCachePromoLocalized
GO

create procedure dbo.PromoSvcCachePromoLocalized
as
set nocount on
set transaction isolation level read uncommitted

SELECT
	dbo.fGetRegionID() as RegionID
	,pp.PromoID
	,pp.LanguageID
	,pp.PromoPageName
	,pp.PromoPageImage
	,pp.ImageAltTag
	,pp.DescriptionTitle AS PromoPageDescBold
	,pp.PromoPageDesc
	,pp.IconBoldText
	,pp.IconText
	,pp.PromoPageCode
	,pp.ExternalURL
	,pp.MetaPageTitle
	,pp.MetaDescription
	,pp.MetaKeyword
	,pp.LinkLabel
	,pp.ExpireMessage
	,pp.LinkText
	,ppi.ImageName as ThumbnailPromoPageImageName
	,pp.MobilePromoPageImage as MobileMastheadImage
	,pp.MobilePromoPageDesc as MobileDescription
	,pp.MastheadUrl
	,pp.QualifyConfMessage
	,pp.ExclusionMessage
FROM dbo.PromoPages pp
LEFT OUTER JOIN dbo.PromoPageImage ppi on pp.ThumbnailPromoPageImageID  = ppi.PromoPageImageID

go


grant execute on PromoSvcCachePromoLocalized to ExecuteOnlyRole

GO

