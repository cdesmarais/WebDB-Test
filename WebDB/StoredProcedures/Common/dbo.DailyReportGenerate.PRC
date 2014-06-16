if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DailyReportGenerate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DailyReportGenerate]
GO

CREATE PROCEDURE dbo.DailyReportGenerate
(
@strDateOffset int,
@recover int = null
)
AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @step int
declare @curstep int
if @recover = 1
begin
	select @step = max(reportid) from dailyreport
	delete dailyreport where reportid = @step
end
else
begin
	set @step = null
	truncate table DailyReport
end


declare @YesterdayResos int   ---## Formarly RC
set @curstep = 0
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_NewResos @curstep,  @strDateOffset, @YesterdayResos output

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosAndCoversBreakdown @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_AAUserStats @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_CancelledResosDay @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosXWeeksAgo @curstep, 3

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosXWeeksAgo @curstep, 2

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosXWeeksAgo @curstep, 1

--g_uc = rs2("JITC") + rs2("Conversions") + rs2("StandardReg")
declare @TotalConversions int  -- ## Formarly uc
set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_NewMembers @curstep,  @strDateOffset, @TotalConversions output


set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosXMonthsAgo @curstep, 3,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosXMonthsAgo @curstep, 2,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosXMonthsAgo @curstep, 1,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_TotalActiveUsers @curstep, 1,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_FirstTimeInStoreCoversXDaysAgo @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_InStoreCoversXDaysAgo @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_IncentedResosXDaysAgo @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_TotalIncentedResoCount @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_YesterdayIncentedResoPoints @curstep,  @strDateOffset


set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_JITResos @curstep,  @strDateOffset


set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_RestResoCount @curstep,  @strDateOffset


set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosByMetroArea @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_HistoricalByMetroArea @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_UsersByMetroAreaYesterday @curstep,  @strDateOffset


set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosYesterdayByCoBrand @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosTotalByCoBrand @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_NewUsersByCoBrand @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_TotalNewUsersByCoBrand @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosYesterdayByPartner @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ResosTotalByPartner @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_RegistrationsYesterdayByPartner @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_RegistrationsTotalByPartner @curstep

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_ActiveRestaurantsByMetroArea @curstep


set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_GetHotelResoCount @curstep,  @strDateOffset

set @curstep = @curstep + 1
if (coalesce(@step, @curstep)<= @curstep)
	exec Daily_HotelResoCount @curstep,  @strDateOffset

insert into DailyReport (reportid, linenum, txt) values(9999, 1, '')


declare @dbName nvarchar(100)
declare @website nvarchar(100)
select @dbName = db_name(db_id())

--******************
--** Conditionally Correct Email subject line title
--******************
if (@dbName = 'Webdb')
	set @website = 'North America Website:' 
else if (@dbName = 'Webdb_ASIA')
	set @website = 'Asia Website:' 
else if (@dbName = 'Webdb_EU')
	set @website = 'European Website:' 


declare @strYesterday datetime
declare @EmailSubject nvarchar(4000)
set @strYesterday = getdate() - @strDateOffset
set @EmailSubject = 'Stats for '+ @website + cast(month(@strYesterday) as nvarchar(20))
	 + '/' + cast(day(@strYesterday) as nvarchar(20)) + '/' + cast(year(@strYesterday) as nvarchar(20))
	+ ': ' + cast(@YesterdayResos as nvarchar(20)) + '/' + cast(@TotalConversions as nvarchar(20))

insert into DailyReport (reportid, linenum, txt) values(-1, 1, @EmailSubject)		
go

GRANT EXECUTE ON [DailyReportGenerate] TO ExecuteOnlyRole

GO
