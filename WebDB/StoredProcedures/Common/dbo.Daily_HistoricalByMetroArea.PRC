if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_HistoricalByMetroArea]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_HistoricalByMetroArea]
GO

create proc dbo.Daily_HistoricalByMetroArea 
(
@rptID int,
@strDateOffset int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select count(ResID) as ReservationCount
	,sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers
	, ma.MetroAreaName as MetName 
	from Reservation r
	INNER JOIN RestaurantVW rt
	ON r.RID = rt.RID 
	inner join Neighborhood n 
	on rt.NeighborhoodID = n.NeighborhoodID 
	inner join MetroAreaAVW ma
	on ma.MetroAreaID = n.MetroAreaID
	and ma.LanguageID = rt.LanguageID
	where RStateID in(1,2,5,6,7) 
	and ma.MetroAreaID <> 1
	and r.datemade>=dbo.fGetDatePart(getdate()-(30+@strDateOffset))
	and r.datemade<=dbo.fGetDatePart(getdate()-(@strDateOffset))
	group by ma.MetroAreaName 
	order by reservationCount desc

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + '30 Day Trailing Reservations by Metro Area: (covers)' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)


--cursor
	Declare @ReservationCount nvarchar(255)
	Declare @Covers nvarchar(255)
	Declare @MetName nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @ReservationCount, @Covers, @MetName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @MetName + ' : ' + @ReservationCount + ' (' + @Covers + ')' + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @ReservationCount, @Covers, @MetName
	END
	CLOSE rpt_cur

GO

GRANT EXECUTE ON [Daily_HistoricalByMetroArea] TO ExecuteOnlyRole

GO
