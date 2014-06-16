
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportMobileReso]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportMobileReso]
GO

create Procedure [dbo].[JobReportMobileReso] (@MonthOffset int = 0)
As

set nocount on
set transaction isolation level read uncommitted

-- when @MonthOffset=0, it's the current month, while -1 is the previous month

declare @rptDT datetime
declare @startDT datetime
declare @endDT datetime

set @rptDT = dateadd(month, @MonthOffset, GETDATE())
set	@startDT = dateadd(s,0,dateadd(mm, datediff(m,0,@rptDT),0))
set @endDT = dateadd(s,-1,dateadd(mm, datediff(m,0,@rptDT)+1,0))

declare @dbname sysname
SET @dbname = db_name()

If @dbname = 'WebDB' 
begin
select		convert(varchar(6), DateMade, 112) 'Month'
			,PartnerID 'PartnerID'
			,COUNT(1) 'Total Booked Resos'
from		Reservation 
where		Shiftdate > DATEADD(day, -10, @startDT) -- for performance
and			DateMade between @startDT and @endDT
and			PartnerID in (75,84,108,117,123,141,183, 201, 141, 291, 315)
group by	convert(varchar(6), DateMade, 112)
			,PartnerID
order by 	PartnerID
end

else if @dbname like 'WebDB_EU%' 
begin
select		convert(varchar(6), DateMade, 112) 'Month'
			,PartnerID 'PartnerID'
			,COUNT(1) 'Total Booked Resos'
from		Reservation 
where		Shiftdate > DATEADD(day, -10, @startDT) -- for performance
and			DateMade between @startDT and @endDT
and			PartnerID in (87,1522,1007,1043,1004)
group by	convert(varchar(6), DateMade, 112)
			,PartnerID
order by 	PartnerID
end

else
begin
select		convert(varchar(6), DateMade, 112) 'Month'
			,PartnerID 'PartnerID'
			,COUNT(1) 'Total Booked Resos'
from		Reservation 
where		Shiftdate > DATEADD(day, -10, @startDT) -- for performance
and			DateMade between @startDT and @endDT
and			PartnerID in (108,90,1025,87)
group by	convert(varchar(6), DateMade, 112)
			,PartnerID
end

					
GO

GRANT EXECUTE ON [dbo].[JobReportMobileReso] TO DTR_User

GO
