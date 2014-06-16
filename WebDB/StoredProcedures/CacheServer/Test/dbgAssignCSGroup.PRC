--$ create proc dbgAssignCSGroup
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dbgAssignCSGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[dbgAssignCSGroup]
go
create proc dbgAssignCSGroup(@GroupID int, @RIDBegin int, @RIDEnd int = null)
as

	if @RIDEnd is not null
	begin
		update	ERBREstaurant 
		set		CacheServerERBGroupID = @GroupID 
		where	RID >= @RIDBegin 
		and		RID <= @RIDEnd
	end

	if @RIDEnd is null
	begin
		update	ERBREstaurant 
		set		CacheServerERBGroupID = @GroupID 
		where	RID = @RIDBegin
	end

go
