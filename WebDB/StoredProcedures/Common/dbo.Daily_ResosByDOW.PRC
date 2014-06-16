if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosByDOW]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosByDOW]
GO

create proc dbo.Daily_ResosByDOW
(
@rptID int,
@strDateOffset int
)
as

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select datepart(weekday, r.DateMade) as resoDay
	,count(datepart(weekday, r.DateMade)) as resocount
	,LEFT(cast((count(datepart(weekday, DateMade))* 100.0)/(select count(*) from Reservation r 
	where r.RStateID in (1,2,5)
	and r.datemade>=dbo.fGetDatePart(getdate()-(7+@strDateOffset))
	and r.datemade<=dbo.fGetDatePart(getdate()-(@strDateOffset))) as char(16)), 4) as resoPercent
	from Reservation r where r.RStateID in (1,2,5,6,7)
	and r.datemade>=dbo.fGetDatePart(getdate()-(7+@strDateOffset))
	and r.datemade<=dbo.fGetDatePart(getdate()-(@strDateOffset))
	group by datepart(weekday, r.DateMade) 
	order by datepart(weekday, r.DateMade) asc

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + '7 Day Trailing Resos by Day of Week (Sunday = 1, Monday = 2, etc.): ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)


--cursor
	declare @resoDay as nvarchar(255)
	declare @resocount as nvarchar(255)
	declare @resoPercent as nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @resoDay, @resocount, @resoPercent

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @ResoDay + ' : ' + @ResoPercent + ' (' + @ResoCount + ')' + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @resoDay, @resocount, @resoPercent
	END
	CLOSE rpt_cur

GO

GRANT EXECUTE ON [Daily_ResosByDOW] TO ExecuteOnlyRole

GO
