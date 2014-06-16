if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Get_Restaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Get_Restaurants]
GO

create procedure dbo.Admin_Get_Restaurants(
 @MetroAreaID int = 0
)
As  
SET NOCOUNT ON  
set transaction isolation level read uncommitted  
  
declare @QAMode int
select	@QAMode = ValueInt 
from	valuelookup 
where	Ltype = 'DATABASE'
and		Lkey = 'CHARM_REST_CACHE_QA_MODE'

if @MetroAreaID <> 0
-- Select Restaurant information for MetroAreaID
begin
	select   
	   r.RID as restaurant_ID  
	   ,r.RestStateID as Restaurant_State_ID  
	   ,r.RName as Name  
	   ,n.metroareaid as Metro_Area_ID  
	   ,m.MetroAreaName as Metro_Name  
	   ,r.UpdatePwd as Update_Password  
	   ,m.Active  
	   ,n.neighborhoodid as Neighborhood_ID  
	   ,n.NbHoodName as Neighborhood  
	   ,r.RSName
	   ,r.Allotment
       ,r.RestaurantType
	   ,(
			case 
				when r.RestaurantType = 'A'
					then 1
				when r.RestaurantType = 'G'
					then 	dbo.fIsGuestBridgeERBCCDisabled(erb.ERBversion)
				else  ---  'E'  ERB restaurants
					dbo.fIsPre80ERBAndCCDisabled(erb.ERBversion)
			end 
	     ) as ccDisabled
	from  RestaurantVW r  
	
	inner join NeighborhoodAVW n   
	on   n.neighborhoodid = r.neighborhoodid  
	and   n.LanguageID = r.LanguageID  
	
	inner join MetroAreaAVW m   
	on   m.metroareaid = n.metroareaid  
	and   m.LanguageID = r.LanguageID  
	
	inner join ERBRestaurant  erb
	on erb.RID = r.RID
	
	-- Add a filter to remove place holder restaurants  
	where  rname not like 'HardKohr%'   
	and   rname not like 'SimTest%'
	and m.metroareaid = @MetroAreaID  
	
	order by r.RSName, r.RName
end
else  
-- select all Restaurant information.
begin
	Select   
	   r.RID as restaurant_ID  
	   ,r.RestStateID as Restaurant_State_ID  
	   ,r.RName as Name  
	   ,n.metroareaid as Metro_Area_ID  
	   ,m.MetroAreaName as Metro_Name  
	   ,r.UpdatePwd as Update_Password  
	   ,m.Active  
	   ,n.neighborhoodid as Neighborhood_ID  
	   ,n.NbHoodName as Neighborhood  
	   ,r.RSName
	   ,r.Allotment
	   ,r.RestaurantType
	   ,(
			case 
				when r.RestaurantType = 'A'
					then 1
				when r.RestaurantType = 'G'
					then 	dbo.fIsGuestBridgeERBCCDisabled(erb.ERBversion)
				else  ---  'E'  ERB restaurants
					dbo.fIsPre80ERBAndCCDisabled(erb.ERBversion)
			end 
	     ) as ccDisabled
	from  RestaurantVW r  
	
	inner join NeighborhoodAVW n   
	on   n.neighborhoodid = r.neighborhoodid  
	and   n.LanguageID = r.LanguageID  
	
	inner join MetroAreaAVW m   
	on   m.metroareaid = n.metroareaid  
	and   m.LanguageID = r.LanguageID  
	
	inner join ERBRestaurant  erb
	on erb.RID = r.RID
	
	-- Add a filter to remove place holder restaurants  
	where  rname not like 'HardKohr%'   
	and   rname not like 'SimTest%' 
	
	and (IsNull(@QAMode,0) = 0 or 
		-- *** If it is in QA Mode only cache the Demoland and Reachable restaurants
		(IsNull(@QAMode,0) = 1 and (m.MetroAreaID = 1 or IsReachable = 1 or Allotment = 1))
		)
	
	order by r.RSName, r.RName
end 

GO

GRANT EXECUTE ON [Admin_Get_Restaurants] TO ExecuteOnlyRole
GO
