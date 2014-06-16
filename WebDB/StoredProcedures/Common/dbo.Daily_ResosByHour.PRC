if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosByHour]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosByHour]
GO

create proc dbo.Daily_ResosByHour
(
@rptID int,
@strDateOffset int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select datepart(hour, r.DateMade) as resohour
	,count(datepart(hour, r.DateMade)) as resocount
	,LEFT(cast((count(datepart(hour, r.DateMade))* 100.0)/(select count(*) from Reservation r where r.RStateID in (1,2,5,6,7)
	and r.datemade>=dbo.fGetDatePart(getdate()-(30+@strDateOffset))
	and r.datemade<=dbo.fGetDatePart(getdate()-(@strDateOffset))) as char(16)), 3) as resoPercent
	from Reservation r 
	where r.RStateID in (1,2,5,6,7)
	and r.datemade>=dbo.fGetDatePart(getdate()-(30+@strDateOffset))
	and r.datemade<=dbo.fGetDatePart(getdate()-(@strDateOffset))
	group by datepart(hour, r.DateMade) 
	order by datepart(hour, r.DateMade) asc


--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + '30 Day Trailing Resos by Hour of Day: ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)

--cursor
	Declare @resohour nvarchar(255)
	Declare @resocount nvarchar(255)
	Declare @resoPercent nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @resohour, @resocount, @resoPercent

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @ResoHour + ' : ' + @ResoPercent + ' (' + @ResoCount + ')' + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @resohour, @resocount, @resoPercent
	END
	CLOSE rpt_cur

GO


GRANT EXECUTE ON [Daily_ResosByHour] TO ExecuteOnlyRole

GO
