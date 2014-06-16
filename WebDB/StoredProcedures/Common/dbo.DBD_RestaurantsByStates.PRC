
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_RestaurantsByStates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_RestaurantsByStates]
GO
 
 



CREATE PROCEDURE dbo.DBD_RestaurantsByStates
(
	@RestState as nvarchar(255),
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
	Select r.RID
			, Rname
			,(CASE 
				 WHEN r.RestStateID = 1 AND isReachable = 1 THEN 'Reserve Now'
				 WHEN r.RestStateID = 1 AND isReachable = 0 THEN 'Back Soon'
				 ELSE RState.RState
				END) as Restaurant_status, n.metroAreaID,
			(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable'  when(coalesce(ListenerVersion, '') != '')  then ListenerVersion else coalesce(Version,'unknown') end) As ListenerVersion,
			(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable' when(coalesce(ErbVersion, '') != '')  then ErbVersion else coalesce(cast(ErbBuild as nvarchar(10)),'unknown') end) As ErbVersion,
			(select Max(StatusChangeDateTS) from restStatusTrackLog where restStatusTrackLog.rid = r.rid and newStatus = r.restStateID) as LastUpdated,
			(select top 1 UserID from restStatusTrackLog 
					where restStatusTrackLog.rid = r.rid and newStatus = r.restStateID
					order by StatusChangeDateTS desc) as LastUpdatedBy
	from		restaurantVW r
	inner join	NeighborhoodAVW n
	on			n.neighborhoodid = r.neighborhoodid
	and			n.LanguageID = r.LanguageID
	inner join	MetroareaAVW m
	on			m.Metroareaid = n.Metroareaid
	and			m.LanguageID = r.LanguageID
	INNER JOIN	Restaurantstate RState
	ON			r.RestStateID   = RState.RestStateID
	inner join	erbrestaurant e
	on			e.rid = r.rid
	where		r.reststateid != 4 
	and			n.metroareaid = @MetroID 
	and			(CASE 
				 WHEN r.RestStateID = 1 AND isReachable = 1 THEN 'Reserve Now'
				 WHEN r.RestStateID = 1 AND isReachable = 0 THEN 'Back Soon'
				 ELSE RState.RState
				END) = @RestState
	order by ListenerVersion desc, 
			ErbVersion desc,
			Rname

END
else
BEGIN
	
	
	Select r.RID
			, Rname
			,CASE 
			 WHEN r.RestStateID = 1 AND isReachable = 1 THEN 'Reserve Now'
			 WHEN r.RestStateID = 1 AND isReachable = 0 THEN 'Back Soon'
			 ELSE RState.RState
			END as Restaurant_status, n.metroAreaID,
			(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable' when(coalesce(ListenerVersion, '') != '')  then ListenerVersion else coalesce(Version,'unknown') end) As ListenerVersion,
			(Case when (restauranttype = 'A' and BrandID = 1) then 'OTConnect-Stable' when (restauranttype = 'A' and BrandID = 2) then 'TTConnect-Stable' when(coalesce(ErbVersion, '') != '')  then ErbVersion else coalesce(cast(ErbBuild as nvarchar(10)),'unknown') end) As ErbVersion,
			(select Max(StatusChangeDateTS) from restStatusTrackLog where restStatusTrackLog.rid = r.rid and newStatus = r.restStateID) as LastUpdated,
			(select top 1 UserID from restStatusTrackLog 
					where restStatusTrackLog.rid = r.rid and newStatus = r.restStateID
					order by StatusChangeDateTS desc) as LastUpdatedBy
			, MetroareaName
	from		restaurantVW r
	inner join	NeighborhoodAVW n
	on			n.neighborhoodid = r.neighborhoodid
	and			n.LanguageID = r.LanguageID
	inner join	MetroareaAVW m
	on			m.Metroareaid = n.Metroareaid
	and			m.LanguageID = r.LanguageID
	INNER JOIN	Restaurantstate RState
	ON			r.RestStateID   = RState.RestStateID
	inner join	erbrestaurant e
	on			e.rid = r.rid
	where r.reststateid != 4 and n.metroareaid != 1 and (CASE 
	 WHEN r.RestStateID = 1 AND isReachable = 1 THEN 'Reserve Now'
	 WHEN r.RestStateID = 1 AND isReachable = 0 THEN 'Back Soon'
	 ELSE RState.RState
	END) = @RestState
	order by ListenerVersion desc, ErbVersion desc, Rname


END
GO


GRANT EXECUTE ON [DBD_RestaurantsByStates] TO ExecuteOnlyRole

GO
