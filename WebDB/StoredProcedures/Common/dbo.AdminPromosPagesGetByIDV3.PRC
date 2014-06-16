



/*Procedure to get the Details for the Promos Pages*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesGetByIDV3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesGetByIDV3]
GO

create procedure dbo.AdminPromosPagesGetByIDV3
(
  @PromoID int
)
as
set nocount on
set transaction isolation level read uncommitted

	select 
		pp.promoid as promo_id
		,promopagename as name
		,promopagedesc as [description]
		,promopagedescdraft as description_draft
		,promopageimage as [image]
		,promopageimagedraft as image_draft
		,ConvertDraftLive
		,selectiondatedraft
		,imagealttag
		,pp.active
		,promosearchtypeid
		,promoicon
		,iconboldtext
		,icontext
		,promopagecode
		,refcodepage
		,refcodelink
		,selectiondate
		,begindate
		,enddate
		,sortorder
		,externalurl
		,suppressdip
		,qualifyconfmessage
		,nonqualifyconfmessage
		,exclusiondate
		,promogrouping
		,eventstartdate
		,eventenddate
		,exclusionmessage
		,displaysearchboxexclusion
		,supporteddomainid
		,SiteDisplayName
		,DescriptionTitle
		,MetaPageTitle
		,MetaDescription
		,MetaKeyword
		,LinkLabel
		,ChildPromoID
		,SuppressPrice
		,ExpireMessage
		,LinkText
		,ShowOnStartPage
		,ThumbnailPromoPageImageID
		,ppi.Imagename as StartPagePromoImg
		,RestaurantWeekPromoStatus = COALESCE (pp2pg.Active,0)
	from   
		PromoPages pp inner join 
		domain d on 
		pp.supporteddomainid = d.domainID 
		
		left outer join 
		promopageexclusions ppe
		on pp.promoid = ppe.promoid 
		
		left outer join 
		PromoPageImage ppi on 
		pp.ThumbnailPromoPageImageID = ppi.PromoPageImageID

		left outer join 
		PromoPagesToPromoGroups pp2pg on
		pp2pg.PromoID = pp.promoid and 
		pp2pg.PromoGroupTypeID = 1

	where  
		pp.promoid = @PromoID

go

grant execute on [AdminPromosPagesGetByIDV3] to ExecuteOnlyRole

go




