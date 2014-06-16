if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetByGroupName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetByGroupName]
go


create proc [dbo].[Admin_Restaurant_GetByGroupName]
(
	@groupname      nvarchar(50)
)
as

	set transaction isolation level read uncommitted

	select 
		 r.RID		  as 'restaurant_id'
		,r.RName	  as 'name'
		,r.City		  as 'city'
		,r.State	  as 'state'
	from [dbo].[RestaurantVW] r
	inner join [dbo].[RestaurantToGroup] rtg on r.RID = rtg.RID 
	inner join [dbo].[RestaurantGroup] g on rtg.GID = g.GID
	where g.Groupname = @groupname 
	order by r.RName

go

GRANT EXECUTE ON [Admin_Restaurant_GetByGroupName] TO ExecuteOnlyRole

GO
