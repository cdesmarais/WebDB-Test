if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetFeaturedPOP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetFeaturedPOP]
GO

create procedure [dbo].[Admin_Restaurant_GetFeaturedPOP]
(
	@metroAreaID	 int
)
as
	set transaction isolation level read uncommitted
	set nocount on
	
	declare @startDate date, @endDate date
	set @startDate = getdate()
	set @endDate = dateadd(dd, 60, @StartDate) 

	select rl.RID, r.RName, rl.SlotNum, rl.StartDate, rl.EndDate 
	from RestaurantFeaturedPOPList rl
	inner  join RestaurantVW r
	on rl.RID = r.RID
	inner join NeighborhoodVW n
	on r.NeighborhoodID = n.NeighborhoodID
	where n.MetroAreaID = @metroAreaID 
		and (rl.StartDate between @startDate  and @endDate OR rl.endDate between @startDate and @endDate)
	order by r.RID
GO

GRANT EXECUTE ON [Admin_Restaurant_GetFeaturedPOP] TO ExecuteOnlyRole
GO
