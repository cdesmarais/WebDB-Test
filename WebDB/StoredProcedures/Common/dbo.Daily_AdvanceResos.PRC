if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_AdvanceResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_AdvanceResos]
GO

create proc dbo.Daily_AdvanceResos
(
@rptID int,
@strDateOffset int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select AdvanceDays, ResoCount, ResoPercent
	from
	(
		select datediff(day,DateMade,ShiftDate) as AdvanceDays
		,count(datediff(day,DateMade,ShiftDate)) as ResoCount
		,left(cast((count(datediff(day,DateMade,ShiftDate))*100.0)/
		(select count(*) from Reservation where RStateID in (1,2,5,6,7)and datemade>=dbo.fGetDatePart(getdate()-(30+@strDateOffset))
		and datemade<=dbo.fGetDatePart(getdate()-(@strDateOffset))) as char(16)),4) as ResoPercent  
		from reservation 
		where RStateID in(1,2,5,6,7) 
		and datemade>=dbo.fGetDatePart(getdate()-(30+@strDateOffset))
		and datemade<=dbo.fGetDatePart(getdate()-(@strDateOffset))
		group by datediff(day,DateMade,ShiftDate)  
		having datediff(day,DateMade,ShiftDate) < 22 

		union 

		select '22' as AdvanceDays
		,count(datediff(day,DateMade,ShiftDate)) as ResoCount
		,left(cast((count(datediff(day,DateMade,ShiftDate))*100.0)/ (select count(RID) from Reservation where RStateID in (1,2,5,6,7)) as char(16)),4) as ResoPercent  
		from reservation
	) as tempTab
	order by AdvanceDays

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + '30 Day Trailing Advance Stats (22 = more than 21 days in advance) : ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)

--cursor
	Declare @AdvanceDays nvarchar(255)
	Declare @ResoCount nvarchar(255)
	Declare @ResoPercent nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @AdvanceDays, @ResoCount, @ResoPercent

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @Advancedays + ' : ' + @ResoPercent + ' (' + @ResoCount + ')' + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @AdvanceDays, @ResoCount, @ResoPercent
	END
	CLOSE rpt_cur

GO


GRANT EXECUTE ON [Daily_AdvanceResos] TO ExecuteOnlyRole

GO
