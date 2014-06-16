
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetByRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetByRID]
go


create proc [dbo].[Admin_Restaurant_GetByRID]
(
	@restaurantidkey       int
)
as

	set transaction isolation level read uncommitted

	select 
		 RID	'restaurant_id'
		,RName	'name'
		,City	'city'
		,State	'state'
	from [dbo].[RestaurantVW] r
	where RID = @restaurantidkey
	
	go
	
GRANT EXECUTE ON [Admin_Restaurant_GetByRID] TO ExecuteOnlyRole

GO
