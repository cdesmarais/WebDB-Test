

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ROMS_Get_ERBVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[ROMS_Get_ERBVersion]
go

create procedure [dbo].[ROMS_Get_ERBVersion]  
as      
    
    select
		er.RID,
		er.ERBVersion
    from
    
    ERBRestaurant er
    inner join RestaurantVW restv
    on er.RID = restv.RID

go

grant execute on [ROMS_Get_ERBVersion] to ExecuteOnlyRole

go

