if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalActiveUsers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalActiveUsers]
GO

CREATE PROCEDURE dbo.Daily_TotalActiveUsers
(
@rptID int,
@strMonthOffset int,
@strDateOffset int,
@strMonthOffsetValue int =0
)
as
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @BeginDate datetime
declare @EndDate datetime
declare @CurrentDate datetime

set @CurrentDate = (getdate()  -@strDateOffset)
		

select @strMonthOffsetValue = 
	case 
	when @strMonthOffset  = 6 then 240
	when @strMonthOffset  = 5 then 210
	when @strMonthOffset  = 4 then 180
	when @strMonthOffset  = 3 then 150
	when @strMonthOffset  = 2 then 120
	when @strMonthOffset  = 1 then 90
end

set @BeginDate = @CurrentDate - @strMonthOffsetValue
set @EndDate = @CurrentDate

declare @custcount integer

select @custcount = count(Customer.CustID) 
from Customer 
where CustID in (
	select c.CustID 
	from Customer c
	,Reservation res
	inner join Restaurant r 
	on res.RID = r.RID
	inner join Neighborhood n 
	on r.neighborhoodid = n.neighborhoodid
	where c.CustID = res.CustID 
	and res.ShiftDate >= @BeginDate
	and res.ShiftDate <= @EndDate
	and res.RStateID not in (3,4,8,9,10)
	and n.metroareaid <> 1
group by c.CustID 
having count(c.CustID) >= 1) 

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set	@strReport = ('Total active users (at least 1 resos) in the last 90 days: ') + cast(@custcount as nvarchar(20)) + @vbnewline

insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

GO

GRANT EXECUTE ON [Daily_TotalActiveUsers] TO ExecuteOnlyRole

GO
