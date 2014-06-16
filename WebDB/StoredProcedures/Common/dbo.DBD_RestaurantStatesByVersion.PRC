
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_RestaurantStatesByVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_RestaurantStatesByVersion]
GO


CREATE PROCEDURE dbo.DBD_RestaurantStatesByVersion
(
	@ListenerVerion as nvarchar(25),
	@ErbVersion as nvarchar(25),
	@MetroID as int

)

  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @AllRestaurants as int

--Select @AllRestaurants = count(*) from restaurant
--inner join neighborhood on r.neighborhoodid = n.neighborhoodid
--where reststateid != 4 and metroareaid != 1

if @MetroID != 0
BEGIN
	
	Select		r.RID
				, Rname, 
				(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable' when(coalesce(ListenerVersion, '') != '')  then ListenerVersion else coalesce(Version,'unknown') end) As ListenerVersion,
				(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable' when(coalesce(ErbVersion, '') != '')  then ErbVersion else coalesce(cast(ErbBuild as nvarchar(10)),'unknown') end) As ErbVersion,
				@AllRestaurants as AllRestaurants
				,CASE 
				 WHEN r.RestStateID = 1 AND isReachable = 1 THEN 'Reserve Now'
				 WHEN r.RestStateID = 1 AND isReachable = 0 THEN 'Back Soon'
				 ELSE RState.RState
				END as Restaurant_status
				, metroAreaID
	
	from		Erbrestaurant e
	inner join	restaurantVW r
	on			e.rid = r.rid
	inner join	neighborhoodAVW n
	on			n.neighborhoodid = r.neighborhoodid
	and			n.LanguageID = r.LanguageID
	INNER JOIN	Restaurantstate RState
	ON			r.RestStateID   = RState.RestStateID
	where		r.reststateid not in (4,2) 
	and			metroareaid = @MetroID
	and			(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable' when(coalesce(ListenerVersion, '') != '')  then ListenerVersion else coalesce(Version,'unknown') end) = @ListenerVerion
	and			(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable' when(coalesce(ErbVersion, '') != '')  then ErbVersion else coalesce(cast(ErbBuild as nvarchar(10)),'unknown') end) = @ErbVersion
	order by Restaurant_status, Rname
END
else
BEGIN
	
	Select	r.RID, Rname, 
			(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable' when(coalesce(ListenerVersion, '') != '')  then ListenerVersion else coalesce(Version,'unknown') end) As ListenerVersion,
			(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable' when(coalesce(ErbVersion, '') != '')  then ErbVersion else coalesce(cast(ErbBuild as nvarchar(10)),'unknown') end) As ErbVersion,
			@AllRestaurants as AllRestaurants
			,CASE 
			 WHEN r.RestStateID = 1 AND isReachable = 1 THEN 'Reserve Now'
			 WHEN r.RestStateID = 1 AND isReachable = 0 THEN 'Back Soon'
			 ELSE RState.RState
			END as Restaurant_status
			, metroAreaID
	
	from		Erbrestaurant e
	inner join	restaurantVW r
	on			e.rid = r.rid
	inner join	neighborhoodAVW n
	on			n.neighborhoodid = r.neighborhoodid
	and			n.LanguageID = r.LanguageID
	INNER JOIN	Restaurantstate RState
	ON			r.RestStateID   = RState.RestStateID

	where		r.reststateid not in (4,2) and metroareaid != 1
	and			(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable' when(coalesce(ListenerVersion, '') != '')  then ListenerVersion else coalesce(Version,'unknown') end) = @ListenerVerion
	and			(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable' when(coalesce(ErbVersion, '') != '')  then ErbVersion else coalesce(cast(ErbBuild as nvarchar(10)),'unknown') end) = @ErbVersion
	order by Restaurant_status, Rname
END
GO




GRANT EXECUTE ON [DBD_RestaurantStatesByVersion] TO ExecuteOnlyRole

