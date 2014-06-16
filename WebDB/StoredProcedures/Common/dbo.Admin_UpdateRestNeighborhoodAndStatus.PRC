
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdateRestNeighborhoodAndStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdateRestNeighborhoodAndStatus]
go

create procedure [dbo].[Admin_UpdateRestNeighborhoodAndStatus]
(
	@RID int
	,@NBHoodId int
	,@RStateId int
)
as

update 
	Restaurant 
set 
	NeighborhoodID = @NBHoodId
	,RestStateID = @RStateId
where 
	RID = @RID

go

GRANT EXECUTE ON [Admin_UpdateRestNeighborhoodAndStatus] TO ExecuteOnlyRole

go

