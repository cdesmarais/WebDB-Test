if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalCoverCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalCoverCount]
GO

CREATE PROCEDURE dbo.Daily_TotalCoverCount
(
@rptID int,
@strDateOffset int,
@TotalCovers int output
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @CoverCount as integer

SELECT @CoverCount = sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)
FROM Reservation 
inner join Restaurant r
on r.RID = Reservation.RID 
inner join Neighborhood n 
on n.neighborhoodid = r.neighborhoodid 
where RStateID in(1,2,5,6,7) 
and n.metroareaid <> 1
and datediff(d,Reservation.DateMade,getdate()-@strDateOffset) >=0

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = ('Total overall covers: ') + cast(@CoverCount as nvarchar(20)) + @vbnewline

insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

set @TotalCovers = @CoverCount

GO

GRANT EXECUTE ON [Daily_TotalCoverCount] TO ExecuteOnlyRole

GO
