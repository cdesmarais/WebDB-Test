if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosByMetroArea]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosByMetroArea]
GO

CREATE proc dbo.Daily_ResosByMetroArea
(
@rptID	int,
@strDateOffset int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select count(r.ResID) as ReservationCount
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
	where r.RStateID in(1,2,5,6,7) and ma.MetroAreaID <> 1
	and datediff(d,r.DateMade,getdate()- @strDateOffset) = 0
	group by ma.MetroAreaName 
	order by ReservationCount desc
	
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)


set @strReport = @vbnewline + 'Reservations by Metro Area - Yesterday: (covers)' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)


--cursor
	Declare @i int
	Declare @ReservationCount nvarchar(255)
	Declare @Covers nvarchar(255)
	Declare @MetName nvarchar(255)

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

GRANT EXECUTE ON [Daily_ResosByMetroArea] TO ExecuteOnlyRole

GO
