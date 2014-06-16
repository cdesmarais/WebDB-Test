if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalIncentivePoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalIncentivePoints]
GO

CREATE proc dbo.Daily_TotalIncentivePoints 
(
@rptID int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare @PointTotal  int

select @PointTotal = coalesce(sum(ResPoints),0)  
from Reservation r
inner join restaurant 
on restaurant.RID = r.RID 
inner join Neighborhood n 
on n.NeighborhoodID = restaurant.NeighborhoodID 
where RStateID in(1,2,5,6,7) 
and n.MetroAreaID <> 1
and r.IncentiveID IS NOT NULL


declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = '/' + cast(@PointTotal as nvarchar(20)) + @vbnewline
	
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

GO

GRANT EXECUTE ON [Daily_TotalIncentivePoints] TO ExecuteOnlyRole

GO
