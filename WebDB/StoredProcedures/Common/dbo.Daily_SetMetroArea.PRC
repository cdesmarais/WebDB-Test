if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_SetMetroArea]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_SetMetroArea]
GO

create proc dbo.Daily_SetMetroArea
(
@rptID int
)
as

set nocount on
set transaction isolation level read uncommitted 

declare rpt_cur2 
CURSOR LOCAL READ_ONLY STATIC FOR

	select ma.MetroAreaname 
	, r.RName as name
	,sum((Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)) as Covers
	,left(cast(avg((Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) * 1.0) as char(10)), 3) as PerResoAverage
	,LEFT(cast((sum((Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)))/ ((CASE(datediff(day, min(rs.DateMade), getDate()))  
												WHEN 0 THEN 1 
												ELSE (datediff(day, min(rs.DateMade), getDate())) 
												END) * 1.00)  as char(20)), 4) as PerDayAvg  
	from restaurantVW r
	inner join reservation rs
		on r.RID = rs.RID
	inner join NeighborhoodAVW n
		on r.NeighborhoodID = n.NeighborhoodID 
		and r.LanguageID = n.LanguageID 
	inner join MetroAreaAVW ma
		on  n.MetroAreaID =  ma.MetroAreaID
		and r.LanguageID = ma.LanguageID
	where  r.RestStateID = 1 
	and  rs.RStateID in (1,2,5,6,7) 
	and  ma.Active = 1 
	and		ma.MetroAreaID <> 1 
	group by ma.MetroAreaName, r.RName 
	order by ma.MetroAreaName, Covers desc

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

--cursor
	Declare @MetroAreaname nvarchar(255)
	Declare @OldMetroName nvarchar(255)
	Declare @name nvarchar(255)
	Declare @Covers nvarchar(255)
	Declare @PerResoAverage nvarchar(255)
	Declare @PerDayAvg nvarchar(255)
	
	Declare @i int

	set @OldMetroName = ''
	set @i = 0
	
	OPEN rpt_cur2
	FETCH NEXT FROM rpt_cur2
	INTO @MetroAreaname, @name, @Covers, @PerResoAverage, @PerDayAvg

	WHILE @@FETCH_STATUS = 0
	BEGIN
		if (@MetroAreaname != @OldMetroName)
		begin
			set @i = @i + 1
			set @strReport = @vbnewline + 'Covers for: ' + @MetroAreaname + @vbnewline
			insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		
		end
		set @OldMetroName = @MetroAreaname
		set @i = @i + 1
		set @strReport = @name + ' : ' + @Covers + ' avg: ' + @PerResoAverage + ' PerDayAverage: ' + @PerDayAvg + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur2
		INTO @MetroAreaname, @name, @Covers, @PerResoAverage, @PerDayAvg
	END
	CLOSE rpt_cur2


GO


GRANT EXECUTE ON [Daily_SetMetroArea] TO ExecuteOnlyRole

GO
