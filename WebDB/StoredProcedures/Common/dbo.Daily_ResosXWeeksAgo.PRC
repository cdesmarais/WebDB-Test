if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosXWeeksAgo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosXWeeksAgo]
GO

CREATE PROCEDURE dbo.Daily_ResosXWeeksAgo
(
@rptID int,
@strWeekOffset int,
@strBeginDate int = 0,
@strEndDate int = 0
)
as
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @ReservationCount as integer

if 	@strWeekOffset = 3 
	BEGIN 
		SET @strBeginDate = 14
		SET @strEndDate =7
	END
if 	@strWeekOffset = 2
	BEGIN 
		SET @strBeginDate = 7
		SET @strEndDate =0
	END
if 	@strWeekOffset = 1
	BEGIN 
		SET @strBeginDate = 0
		SET @strEndDate =0

		select @ReservationCount = count(Reservation.ResID)
		from  Reservation 
		inner join Restaurant r on  r.RID = Reservation.RID 
		inner join Neighborhood n on n.neighborhoodid = r.neighborhoodid 
		where DateMade > (RTRIM(cast(datepart(month,(getDate() - ((datepart(weekday,getDate()) - 1))- @strBeginDate)) as char(10))) + '-' +
		RTRIM(cast(datepart(day,(getDate() - ((datepart(weekday,getDate()) - 1))- @strBeginDate)) as 
		char(2))) + '-'
		+ cast(datepart(year,(getDate() - ((datepart(weekday,getDate()) - 1))- @strBeginDate)) as char(4)))
		and RStateID in (1,2,5,6,7) 
		and n.metroareaid <> 1 	 
	END
ELSE
	BEGIN
		select @ReservationCount = count(Reservation.ResID)
		from  Reservation 
		inner join Restaurant r on  r.RID = Reservation.RID 
		inner join Neighborhood n on n.neighborhoodid = r.neighborhoodid 
		where DateMade >= (RTRIM(cast(datepart(month,(getDate() - ((datepart(weekday,getDate()) - 1))- @strBeginDate)) as char(10))) + '-' +
		RTRIM(cast(datepart(day,(getDate() - ((datepart(weekday,getDate()) - 1))- @strBeginDate)) as 
		char(2))) + '-'
		+ cast(datepart(year,(getDate() - ((datepart(weekday,getDate()) - 1))- @strBeginDate)) as char(4)))
		and DateMade <= (RTRIM(cast(datepart(month,(getDate() - ((datepart(weekday,getDate()) - 
		1))- @strEndDate)) as char(10))) + '-' +
		RTRIM(cast(datepart(day,(getDate() - ((datepart(weekday,getDate()) - 1))- @strEndDate)) as char(2))) 
		+ '-' + cast(datepart(year,(getDate() - ((datepart(weekday,getDate()) - 1))- @strEndDate)) as char(4)))
		and RStateID in (1,2,5,6,7) 
		and n.metroareaid <> 1 	 
	END


declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

if 	@strWeekOffset = 3
	begin
			set @strReport = 'Three week Reso trend: '
	end
else
	begin
			set @strReport = '/'
	end

set @strReport = @strReport + cast(@ReservationCount as nvarchar(20)) 

if 	@strWeekOffset = 1
begin
	set @strReport = @strReport + @vbnewline
end	
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)
	
GO

GRANT EXECUTE ON [Daily_ResosXWeeksAgo] TO ExecuteOnlyRole

GO
