if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_NewResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_NewResos]
GO

CREATE PROCEDURE dbo.Daily_NewResos 
(
@rptID int,
@strDateOffset int,
@YesterdayResos int output
)


AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @YResos as integer
declare @YCovers as integer


select @YResos = count(ResID),
	@YCovers = sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)
from Reservation 
inner join Restaurant r on  r.RID = Reservation.RID 
inner join Neighborhood n on n.neighborhoodid = r.neighborhoodid 
where RStateID in(1,2,5,6,7) 
and n.metroareaid <> 1 
and datediff(d,DateMade,getdate()- @strDateOffset) = 0

select @YResos = Coalesce(@YResos,0),
		@YCovers = Coalesce(@YCovers,0)

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = ('Total new resos/covers: ')  + cast(@YResos as nvarchar(20))  + '/' + cast(@YCovers as nvarchar(20)) + @vbnewline

insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

set @YesterdayResos = @YResos

GO

GRANT EXECUTE ON [Daily_NewResos] TO ExecuteOnlyRole

GO
