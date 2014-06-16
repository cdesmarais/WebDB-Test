if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalFirstTimeCovers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalFirstTimeCovers]
GO

CREATE PROCEDURE dbo.Daily_TotalFirstTimeCovers

(
@rptID int,
@strDateOffset int,
@CoverCount int
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @TotalFirstTime int

select @TotalFirstTime  = sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)
from Reservation 
inner join Restaurant r on  r.RID = Reservation.RID 
inner join Neighborhood n on n.neighborhoodid = r.neighborhoodid 
where RStateID in(1,2,5,6,7) 
and datediff(d,Reservation.DateMade,getdate()-@strDateOffset) >=0
and Reservation.FirstTime = 1
and n.metroareaid <> 1

select     @TotalFirstTime = coalesce(@TotalFirstTime , 0)

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = 'Total First Time in Store covers/total covers: ' + cast(@TotalFirstTime as nvarchar(20)) 
	+ '/' + cast(@CoverCount as nvarchar(20)) + @vbnewline

	
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

GO

GRANT EXECUTE ON [Daily_TotalFirstTimeCovers] TO ExecuteOnlyRole

GO
