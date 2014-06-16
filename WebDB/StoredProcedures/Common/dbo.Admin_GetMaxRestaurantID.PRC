if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetMaxRestaurantID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetMaxRestaurantID]
go

create procedure [dbo].[Admin_GetMaxRestaurantID]
	@MaxCachedRID int
as

declare @RetMaxRID int = 0
	/*
		This proc gets the Max RID from the restaurant table
	*/
	 set transaction isolation level read uncommitted
	 
	 select top 1 @RetMaxRID = RID  
	 from Restaurant
	 where RID > @MaxCachedRID
	 order by RID desc
	 
	 if @RetMaxRID = 0 
	 set @RetMaxRID = @MaxCachedRID
	 
	 select @RetMaxRID as MaxRestaurantID
go

grant execute on [Admin_GetMaxRestaurantID] to ExecuteOnlyRole

go