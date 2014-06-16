if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_IncentedResosXDaysAgo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_IncentedResosXDaysAgo]
GO

CREATE PROCEDURE dbo.Daily_IncentedResosXDaysAgo

(
@rptID int,
@strDateOffset int
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @IncentiveCount int
declare @Covers int

select @IncentiveCount = count(ResID) 
	, @Covers = sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)
from Reservation 
inner join Restaurant r 
on r.RID = Reservation.RID  
inner join Neighborhood n 
on n.neighborhoodid = r.neighborhoodid  
where RStateID in(1,2,5,6,7) 
and n.metroareaid <> 1 
and datediff(d,Reservation.DateMade,getdate() - @strDateOffset) = 0 
and coalesce(Reservation.incentiveid,0) != 0

select     @Covers = coalesce(@Covers , 0)

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = 'Total Incented Resos yesterday(covers)/Overall(covers): ' + cast(@IncentiveCount as nvarchar(20)) + '(' + cast(@Covers as nvarchar(20)) + ')'
	
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

GO

GRANT EXECUTE ON [Daily_IncentedResosXDaysAgo] TO ExecuteOnlyRole

GO
