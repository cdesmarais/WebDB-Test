if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_SearchByName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_SearchByName]
go


create proc [dbo].[Admin_Restaurant_SearchByName]
(
	@keywords       nvarchar(50)
)
as

	set transaction isolation level read uncommitted

	select top 50 
		 RID	'restaurant_id'
		,RName	'name'
		,City	'city'
		,State	'state'
	from dbo.RestaurantVW r
	where RName like '%' + @keywords + '%'
	order by RName
	
go
	
GRANT EXECUTE ON [Admin_Restaurant_SearchByName] TO ExecuteOnlyRole

GO

