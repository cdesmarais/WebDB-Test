
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_RestaurantVersionByState]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_RestaurantVersionByState]
GO


CREATE PROCEDURE dbo.DBD_RestaurantVersionByState
(
	@RestState as nvarchar(255)

)

  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @AllRestaurants as int

Select @AllRestaurants = count(*) from restaurant
inner join neighborhood on restaurant.neighborhoodid = neighborhood.neighborhoodid
where reststateid != 4 and metroareaid != 1

Select count(*) as RestaurantCount, 
(Case 
	when (restauranttype = 'A' and BrandID = 1 AND IsConnectFieldTest = 0) then 'OTConnect-Stable' 
	when (restauranttype = 'A' and BrandID = 2 AND IsConnectFieldTest = 0) then 'TTConnect-Stable' 
	when (restauranttype = 'A' and BrandID = 1 AND IsConnectFieldTest = 1) then 'OTConnect-Field Test' 
	when (restauranttype = 'A' and BrandID = 2 AND IsConnectFieldTest = 1) then 'TTConnect-Field Test' 
	when(coalesce(ListenerVersion, '') != '')  then ListenerVersion 
	else coalesce(Version,'unknown') end) As ListenerVerion,
(Case 
	when (restauranttype = 'A' and BrandID = 1 AND IsConnectFieldTest = 0) then 'OTConnect-Stable' 
	when (restauranttype = 'A' and BrandID = 2 AND IsConnectFieldTest = 0) then 'TTConnect-Stable' 
	when (restauranttype = 'A' and BrandID = 1 AND IsConnectFieldTest = 1) then 'OTConnect-Field Test' 
	when (restauranttype = 'A' and BrandID = 2 AND IsConnectFieldTest = 1) then 'TTConnect-Field Test' 
	when(coalesce(ErbVersion, '') != '')  then ErbVersion 
	else coalesce(cast(ErbBuild as nvarchar(10)),'unknown') end) As ErbVersion,
@AllRestaurants as AllRestaurants

from Erbrestaurant
inner join restaurant on erbrestaurant.rid = restaurant.rid
inner join neighborhood on restaurant.neighborhoodid = neighborhood.neighborhoodid
INNER JOIN Restaurantstate RState
ON         restaurant.RestStateID  = RState.RestStateID
where restaurant.reststateid != 4 and (CASE 
	 WHEN restaurant.RestStateID = 1 AND isReachable = 1 THEN 'Reserve Now'
	 WHEN restaurant.RestStateID = 1 AND isReachable = 0 THEN 'Back Soon'
	 ELSE RState.RState
	END) = @RestState
group by 
(Case 
	when (restauranttype = 'A' and BrandID = 1 AND IsConnectFieldTest = 0) then 'OTConnect-Stable' 
	when (restauranttype = 'A' and BrandID = 2 AND IsConnectFieldTest = 0) then 'TTConnect-Stable' 
	when (restauranttype = 'A' and BrandID = 1 AND IsConnectFieldTest = 1) then 'OTConnect-Field Test' 
	when (restauranttype = 'A' and BrandID = 2 AND IsConnectFieldTest = 1) then 'TTConnect-Field Test' 
	when(coalesce(ListenerVersion, '') != '')  then ListenerVersion 
	else coalesce(Version,'unknown') end),
(Case 
	when (restauranttype = 'A' and BrandID = 1 AND IsConnectFieldTest = 0) then 'OTConnect-Stable' 
	when (restauranttype = 'A' and BrandID = 2 AND IsConnectFieldTest = 0) then 'TTConnect-Stable' 
	when (restauranttype = 'A' and BrandID = 1 AND IsConnectFieldTest = 1) then 'OTConnect-Field Test' 
	when (restauranttype = 'A' and BrandID = 2 AND IsConnectFieldTest = 1) then 'TTConnect-Field Test' 
	when(coalesce(ErbVersion, '') != '')  then ErbVersion 
	else coalesce(cast(ErbBuild as nvarchar(10)),'unknown') end)
order by count(*) desc
GO

GRANT EXECUTE ON [DBD_RestaurantVersionByState] TO ExecuteOnlyRole

GO
