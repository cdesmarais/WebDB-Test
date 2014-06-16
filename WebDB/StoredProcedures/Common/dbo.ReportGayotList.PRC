if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReportGayotList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReportGayotList]

GO

CREATE PROCEDURE dbo.ReportGayotList
(
@IsGayot int
)
as

set nocount on
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

/*This procedure export gayot link/rating detail.  
If @IsGayot is set to 0, we export list of restaurants 
that do not have current Gayot link and listing.  
If @IsGayot is set to 1, we export list of restaurants that currently have Gayot Rating*/

if @IsGayot = 0
begin
	Select	OTArea.metroareaname as [Metro Name],
			OTRest.rname as [Restaurant Name],
			OTPrice.PriceQuartile as Price,
			OTRest.externalurl as URL, 
			OTHood.nbhoodname as Neighborhood,
			OTFood.foodType as FoodType,
			OTRest.address1 as Address,
			OTRest.city, 
			OTRest.state,
			OTRest.ZIP as [Postal Code], 
			OTRest.phone,
			OTRest.rid as [Restaurant ID],
			OTRest.reservecode as [Reserve URL], 
			OTRestMess.RMDesc as [Restaurant Description],
			OTContent.Content as [Gayot Rating], 
			ShortValue as [Gayot Link]
	From restaurantVW OTRest
	 inner join neighborhoodAVW OTHood 
		on OTRest.neighborhoodid = OTHood.neighborhoodid
		and OTRest.LanguageID = OTHood.LanguageID 
	 inner join metroareaAVW OTArea 
		on OTHood.metroareaid = OTArea.metroareaid
		and OTHood.LanguageID = OTArea.LanguageID 
	 inner join restaurantmessageAVW OTRestMess 
		on OTRest.rid = OTRestMess.rid
		and OTRest.LanguageID = OTRestMess.LanguageID
	 inner join foodtypes OTFoods on OTRest.rid = OTFoods.rid
	 inner join foodtype OTFood 
		on OTFoods.foodtypeid = OTFood.foodtypeid
		and OTRest.LanguageID = OTFood.LanguageID
	inner join PriceQuartileAVW OTPrice 
		on OTRest.pricequartileid = OTPrice.pricequartileid
		and OTRest.LanguageID = OTPrice.LanguageID
		and OTRest.Country = OTPrice.CountryID
	 left outer join content OTContent on OTRest.rid = OTContent.rid and ProviderID = 7
	Where OTRest.reststateid not in (4)
	 and OTFoods.isprimary = 1 and OTArea.active = 1
	and content is null and ShortValue is NULL
	Order by OTArea.metroareaname,OTRest.rname
end
else
begin
	Select	OTArea.metroareaname as [Metro Name],
			OTRest.rname as [Restaurant Name],
			OTPrice.PriceQuartile as Price,
			OTRest.externalurl as URL, 
			OTHood.nbhoodname as Neighborhood,
			OTFood.foodType as FoodType,
			OTRest.address1 as Address,
			OTRest.city, 
			OTRest.state,
			OTRest.ZIP as [Postal Code], 
			OTRest.phone,
			OTRest.rid as [Restaurant ID],
			OTRest.reservecode as [Reserve URL], 
			OTRestMess.RMDesc as [Restaurant Description],
			OTContent.Content as [Gayot Rating], 
			ShortValue as [Gayot Link]
	From restaurantVW OTRest
	 inner join neighborhoodAVW OTHood 
		on OTRest.neighborhoodid = OTHood.neighborhoodid
		and OTRest.LanguageID = OTHood.LanguageID 
	 inner join metroareaAVW OTArea 
		on OTHood.metroareaid = OTArea.metroareaid
		and OTHood.LanguageID = OTArea.LanguageID 
	 inner join restaurantmessageAVW OTRestMess 
		on OTRest.rid = OTRestMess.rid
		and OTRest.LanguageID = OTRestMess.LanguageID
	 inner join foodtypes OTFoods on OTRest.rid = OTFoods.rid
	 inner join foodtype OTFood 
		on OTFoods.foodtypeid = OTFood.foodtypeid
		and OTRest.LanguageID = OTFood.LanguageID
	inner join PriceQuartileAVW OTPrice 
		on OTRest.pricequartileid = OTPrice.pricequartileid
		and OTRest.LanguageID = OTPrice.LanguageID
		and OTRest.Country = OTPrice.CountryID
	 inner join content OTContent on OTRest.rid = OTContent.rid and ProviderID = 7
	Where OTRest.reststateid not in (4)
	 and OTFoods.isprimary = 1 and OTArea.active = 1
	and content is not null and ShortValue is not NULL
	Order by OTArea.metroareaname,OTRest.rname

END

GO


GRANT EXECUTE ON [ReportGayotList] TO ExecuteOnlyRole

GO
