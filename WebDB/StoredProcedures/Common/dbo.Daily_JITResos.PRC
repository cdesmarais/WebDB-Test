if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_JITResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_JITResos]
GO

CREATE PROCEDURE dbo.Daily_JITResos

(
@rptID			int,
@strDateOffset int
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @JITYesterday  int


select @JITYesterday = count(Reservation.ResID)
from Reservation 
inner join Customer on Customer.CustID = Reservation.CustID 
inner join Restaurant r on r.RID = Reservation.RID 
inner join Neighborhood n on n.neighborhoodid = r.neighborhoodid 
where datediff(d,Customer.createdate,Reservation.ShiftDate) = 0 
and datediff(d,Reservation.ShiftDate,(getdate()- @strDateOffset)) = 0 
and n.metroareaid <> 1

-- Format Report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = 'Just in Time Resos (yesterday): ' + cast(@JITYesterday as nvarchar(20)) 
				+ @vbnewline
	
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

GO

GRANT EXECUTE ON [Daily_JITResos] TO ExecuteOnlyRole

GO
