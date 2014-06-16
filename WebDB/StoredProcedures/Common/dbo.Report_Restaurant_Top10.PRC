if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Restaurant_Top10]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Restaurant_Top10]
GO

CREATE PROCEDURE dbo.Report_Restaurant_Top10
(
  @metroID int,
  @thrudate Datetime = Null
)
AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

Declare @fromdate datetime, @header nvarchar(50)

If @thrudate is null
	Begin
	Select @thrudate = Cast(convert(nvarchar, getdate(), 101) as datetime) --get request(current) date to range
	End

Select @fromdate = dateadd(d,-7,Cast(@thrudate as datetime)) --get request date from range
Select @header = Cast(@fromdate as nvarchar)+' - '+Cast(@thrudate as nvarchar(50))

Select top 10 (rt.RName + '(' + convert(nvarchar,TopList.Resos) + ')') as Restaurant, @header as date_range
From		RestaurantTopList TopList
inner join	RestaurantVW rt 
on			TopList.RID = rt.RID
inner join	Neighborhood n 
on			rt.NeighborhoodID = n.NeighborhoodID
where		n.MetroAreaID = @metroID
Order by TopList.Resos desc

GO


GRANT EXECUTE ON [Report_Restaurant_Top10] TO ExecuteOnlyRole

GO
