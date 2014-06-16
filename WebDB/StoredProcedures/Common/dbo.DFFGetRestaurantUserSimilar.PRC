if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DFFGetRestaurantUserSimilar]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DFFGetRestaurantUserSimilar]
GO

CREATE Procedure dbo.DFFGetRestaurantUserSimilar(
	@parRID int
)
as
/******************************************************************************
Given a RID, returns a list that is used to render the similar list on the DFF 
Thank You page.
******************************************************************************/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

begin

	-- get similar restaurants
	declare @simRestaurants varchar(8000);
	select 
		@simRestaurants=SimilarList
		from 
		RestaurantUserSimilar
		where
		RID = @parRID
		
	-- get similar restaurant info
	select 
		'<a href=''' + 'http://' + d.publicsite + '/rest_profile.aspx?ref=1120&rid=' + cast(r.rid as varchar) + '''>' + r.RName + '</a>' as RestaurantName,
		n.nbhoodname as NbHood,		
		p.Symbols as PrcQuartile,
		ft.FoodType as Cuisine
	from 
		RestaurantVW r		 
		inner join NeighborhoodVW n 
		on n.neighborhoodid=r.neighborhoodid
		
		inner join PriceQuartileVW p 
		on ((Case when(r.PriceQuartileID=5) then 0 else r.PriceQuartileID end)=p.pricequartileid and p.CountryID = r.Country)
		
		inner join Domain d 
		on d.domainid = r.domainid
		
		inner join FoodTypes fts
			ON (r.RID = fts.RID and fts.IsPrimary=1)
			
		inner join FoodType ft
			ON (ft.FoodTypeID = fts.foodtypeid and ft.LanguageID = r.LanguageID)
		
		where CHARINDEX(',' + CAST(r.RID AS varchar(10)) + '/' , ',' + @simRestaurants) > 0
		
	order by r.rname
end

GO




GRANT EXECUTE ON [DFFGetRestaurantUserSimilar] TO ExecuteOnlyRole

GO
