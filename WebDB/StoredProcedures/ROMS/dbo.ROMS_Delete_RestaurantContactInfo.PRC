if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ROMS_Delete_RestaurantContactInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[ROMS_Delete_RestaurantContactInfo]
go

create procedure [dbo].[ROMS_Delete_RestaurantContactInfo]  
as      
    
    delete from 
    ROMSRestaurantContactInfo

go

grant execute on [ROMS_Delete_RestaurantContactInfo] to ExecuteOnlyRole

go

