if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_RestResoCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_RestResoCount]
GO

CREATE proc dbo.Daily_RestResoCount
(
@rptID int,
@strDateOffset int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	SELECT COUNT(r.RID) AS RestResoCount
		,sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as CoverCount
		, rt.RName
		,ma.MetroAreaName as city
		,ma.MetroAreaID
	from Reservation r 
	INNER JOIN RestaurantVW rt
	ON r.RID = rt.RID 
	inner join Neighborhood n 
	on n.NeighborhoodID = rt.NeighborhoodID 
	inner join MetroAreaAVW ma
	on ma.MetroAreaID = n.MetroAreaID
	and ma.LanguageID = rt.LanguageID 
	where r.RStateID in(1,2,5,6,7) 
	and n.MetroAreaID <> 1
	and datediff(d,r.DateMade,getdate()- @strDateOffset) = 0
	GROUP BY rt.RName
	,ma.MetroAreaName
	,ma.MetroAreaID
	order by RestResoCount desc
	,CoverCount desc
	,rt.RName


declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Yesterday''s reservations: (covers)' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)


--cursor
	Declare @RestResoCount int
	Declare @CoverCount int
	Declare @MetroAreaID int
	Declare @i int
	Declare @RName nvarchar(255)
	Declare @city nvarchar(255)

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @RestResoCount, @CoverCount, @RName, @city, @MetroAreaID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @RName + ' (' + @city + ') : ' + cast(@RestResoCount as nvarchar(20))
						+ ' (' + cast(@CoverCount as nvarchar(20)) + ')' + @vbnewline
		
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @RestResoCount, @CoverCount, @RName, @city, @MetroAreaID
		
		
	END
	CLOSE rpt_cur


GO

GRANT EXECUTE ON [Daily_RestResoCount] TO ExecuteOnlyRole

GO
