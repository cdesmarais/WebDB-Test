if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosXMonthsAgo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosXMonthsAgo]
GO

CREATE PROCEDURE dbo.Daily_ResosXMonthsAgo
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
declare @ResoCount as integer

set @CurrentDate = (getdate()  -@strDateOffset)
		
select @strMonthOffsetValue = 
	case 
	when @strMonthOffset  = 6 then 180
	when @strMonthOffset  = 5 then 150
	when @strMonthOffset  = 4 then 120
	when @strMonthOffset  = 3 then 90
	when @strMonthOffset  = 2 then 60
	when @strMonthOffset  = 1 then 30
end

set @BeginDate = @CurrentDate - @strMonthOffsetValue
set @EndDate = @CurrentDate - (@strMonthOffsetValue -30)

	select @ResoCount = count(Reservation.ResID)
	from Reservation 
	inner join Restaurant r on  r.RID = Reservation.RID 
	inner join Neighborhood n on n.neighborhoodid = r.neighborhoodid 
	where Reservation.DateMade >= @BeginDate
	and Reservation.DateMade <= @EndDate
	and RStateID in (1,2,5,6,7) 
	and n.metroareaid <> 1


declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

if (@strMonthOffset = 3) 
begin
	set	@strReport = 'Three Month Reso trend: '
end
else
begin
	set	@strReport = '/'
end

set	@strReport = @strReport + cast(@ResoCount as nvarchar(20)) 

if (@strMonthOffset = 1) 
begin
	set	@strReport = @strReport + @vbnewline
end

insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)


GO

GRANT EXECUTE ON [Daily_ResosXMonthsAgo] TO ExecuteOnlyRole

GO
