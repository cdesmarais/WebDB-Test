if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_YesterdayIncentedResoPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_YesterdayIncentedResoPoints]
GO

CREATE proc dbo.Daily_YesterdayIncentedResoPoints
(
@rptID		int,
@strDateOffset	int
)

as 

set nocount on
set transaction isolation level read uncommitted

declare @PointTotal int

select @PointTotal = coalesce(sum(ResPoints),0) 
from Reservation r
inner join restaurant rt
on rt.RID = r.RID 
inner join Neighborhood n 
on n.NeighborhoodID = rt.NeighborhoodID 
where RStateID in(1,2,5,6,7) 
and n.MetroAreaID <> 1
and datediff(d,r.DateMade,getdate() - @strDateOffset) = 0
and r.IncentiveID IS NOT NULL


declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = 'Total Points for Incentives yesterday: ' + cast(@PointTotal as nvarchar(20)) + @vbnewline
	
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)
GO

GRANT EXECUTE ON [Daily_YesterdayIncentedResoPoints] TO ExecuteOnlyRole

GO
