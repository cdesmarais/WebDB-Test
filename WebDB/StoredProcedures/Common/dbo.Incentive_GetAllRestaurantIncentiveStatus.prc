
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_GetAllRestaurantIncentiveStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_GetAllRestaurantIncentiveStatus]


go
set quoted_identifier on
go

--USed to get DIP Status information for all retstaurant
create procedure  [dbo].[Incentive_GetAllRestaurantIncentiveStatus]  
@ROMSIDList varchar(8000)=null  
as  
begin   
  
-- Used to get retstaurant's DIP Status information.. 

select	romsRests.RestaurantID,    
		ic.Status		as DIPStatus,    
		irs.StartDate	as DIPCreateDate,    
		irs.EndDate		as DIPCancellationDate,    
		ic.incStatusid	as RestDIPStatusTypeID,  
		irs.RID			as WebRID  
  
from	IncentiveRestaurantStatus irs    
 
inner join IncentiveStatus ic 
on irs.IncStatusID		= Ic.IncStatusID
    
inner join Restaurant r  
on irs.RID				= r.RID
    
inner join RestaurantState rs 
on r.RestStateID		= rs.RestStateID    

inner join yellowstone.god.dbo.Restaurants romsRests
on romsRests.WebID = cast(r.RID as varchar(10))

where	(@ROMSIDList IS NULL OR CHARINDEX(',' + CAST( irs.RID AS nvarchar) + ',', ',' + @ROMSIDList + ',')>0 )
and		irs.Active = 1    

end   
  
GO
GRANT EXECUTE ON [Incentive_GetAllRestaurantIncentiveStatus] TO ExecuteOnlyRole
GO









