if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalNoShowCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalNoShowCount]
GO

CREATE PROCEDURE dbo.Daily_TotalNoShowCount
(
@rptID int,
@strDateOffset int
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @OTConsumer as integer
declare @OTConcierge as integer
declare @OTAdmin as integer


select @OTConsumer = count(Reservation.ResID) 
from Reservation 
inner join Customer on Reservation.CustID = Customer.CustID 
inner join Restaurant r on  r.RID = Reservation.RID 
inner join Neighborhood n on r.neighborhoodid = n.neighborhoodid 
where Reservation.RStateID = 4 and  
n.metroareaid <> 1 and 
Reservation.ShiftDate > '06-01-2000' and
datediff(d,Reservation.ShiftDate,getdate()-@strDateOffset) >=0

select @OTConcierge = count(Reservation.ResID) 
from Reservation 
inner join Caller on Reservation.CallerID = Caller.CallerID 
inner join Restaurant r on  r.RID = Reservation.RID 
inner join Neighborhood n on r.neighborhoodid = n.neighborhoodid 
where Caller.PositionID = 2 and  
Reservation.RStateID = 4 and  
n.metroareaid <> 1 and 
Reservation.ShiftDate > '06-01-2000' and
datediff(d,Reservation.ShiftDate,getdate()-@strDateOffset) >=0

select @OTAdmin = count(Reservation.ResID) from Reservation 
inner join Caller on Reservation.CallerID = Caller.CallerID 
inner join Restaurant r on  r.RID = Reservation.RID 
inner join Neighborhood n on r.neighborhoodid = n.neighborhoodid 
where Caller.PositionID = 3 and 
Reservation.RStateID = 4 and 
n.metroareaid <> 1 and 
Reservation.ShiftDate > '06-01-2000' and
datediff(d,Reservation.ShiftDate,getdate()-@strDateOffset) >=0

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

declare @TotalNS as integer

set	@TotalNS = @OTConsumer + @OTConcierge + @OTAdmin

set @strReport = ('No-shows since 6/1/2000 (T/W/C/A): ') + cast(@TotalNS as nvarchar(20)) + '/' + cast(@OTConsumer as nvarchar(20)) + 
	'/' + cast(@OTConcierge as nvarchar(20)) + '/' + cast(@OTAdmin as nvarchar(20)) + @vbnewline
	

insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)


GO

GRANT EXECUTE ON [Daily_TotalNoShowCount] TO ExecuteOnlyRole

GO
