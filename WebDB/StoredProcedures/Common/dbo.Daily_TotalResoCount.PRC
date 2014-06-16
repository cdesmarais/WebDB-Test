if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalResoCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalResoCount]
GO

CREATE PROCEDURE dbo.Daily_TotalResoCount
(
@rptID int,
@strDateOffset int
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @ReservationCount integer

SELECT @ReservationCount = COUNT(ResID)  
FROM Reservation 
inner join Restaurant r on  r.RID = Reservation.RID 
inner join Neighborhood n on n.neighborhoodid = r.neighborhoodid 
where RStateID in(1,2,5,6,7) 
and n.metroareaid <> 1
and datediff(d,Reservation.DateMade,getdate()-@strDateOffset) >=0

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set	@strReport = ('Total overall reservations: ') + cast(@ReservationCount as nvarchar(20)) + @vbnewline

insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)


GO

GRANT EXECUTE ON [Daily_TotalResoCount] TO ExecuteOnlyRole

GO
