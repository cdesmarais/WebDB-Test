
if  exists (select * from dbo.sysobjects where id = OBJECT_ID(N'[dbo].[ROMS_GetRestaurantDomainInfo]') and type in (N'P', N'PC'))
drop procedure [dbo].[ROMS_GetRestaurantDomainInfo]
go

create Procedure [dbo].[ROMS_GetRestaurantDomainInfo]  
   
as  

	select  
		RID	as WebID
		,DomainId     
	from
	   restaurantVW
 
go

grant execute on [ROMS_GetRestaurantDomainInfo] to ExecuteOnlyRole
go  

