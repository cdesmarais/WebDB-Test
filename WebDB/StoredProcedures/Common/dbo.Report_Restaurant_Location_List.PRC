
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Restaurant_Location_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Restaurant_Location_List]
GO


CREATE PROCEDURE dbo.Report_Restaurant_Location_List

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted


Select OTRest.RID as restaurant_ID
		,OTRest.RName as Name
		,OTNeighbor.metroareaid as Metro_Area_ID
		,OTMetro.MetroAreaName as Metro_Name
		,OTNeighbor.neighborhoodid as Neighborhood_ID
		,OTNeighbor.NbHoodName as Neighborhood
		,OTRest.RestStateID as Restaurant_State_ID
		,RState
		,OTNeighbor.MacroID
		,MacroName 
		,Latitude, Longitude
from		RestaurantVW OTRest
inner join	NeighborhoodAVW OTNeighbor 
on			OTRest.neighborhoodid = OTNeighbor.neighborhoodid
and			OTRest.LanguageID = OTNeighbor.LanguageID
inner join	MetroAreaAVW OTMetro 
on			OTNeighbor.metroareaid = OTMetro.metroareaid
and			OTMetro.LanguageID = OTRest.LanguageID
inner join RestaurantState 
on OTRest.restStateid = RestaurantState.restStateid
inner join MacroNeighborhoodAVW mn
on		OTNeighbor.MacroID = mn.MacroID
and		mn.LanguageID = OTRest.LanguageID
where OTRest.restStateid != 4 and OTMetro.MetroAreaID !=1

GO


GRANT EXECUTE ON [Report_Restaurant_Location_List] TO ExecuteOnlyRole

GO
