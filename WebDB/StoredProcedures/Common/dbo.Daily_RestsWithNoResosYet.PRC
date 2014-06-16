if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_RestsWithNoResosYet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_RestsWithNoResosYet]
GO

create proc dbo.Daily_RestsWithNoResosYet
(
@rptID int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select ma.MetroAreaName as city
		,r.RName as rest_name 
	from restaurantVW r
	inner join	NeighborhoodAVW n 
	on			n.NeighborhoodID = r.NeighborhoodID 
	and			n.LanguageID = r.LanguageID
	inner join	MetroAreaAVW ma
	on			n.MetroAreaID = ma.MetroAreaID 
	and			r.LanguageID = ma.LanguageID
	where RID not in (select RID from Reservation r where RStateID in(1,2,5,6,7)) 
	and r.RestStateID = 1 
	and n.MetroAreaID <> 1 
	order by city
	,RName



--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Restaurants w/ no Resos (yet): ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)


--cursor
	Declare @city nvarchar(255)
	Declare @rest_name nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @city, @rest_name

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @rest_name + ' - ' + @city + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @city, @rest_name
	END
	CLOSE rpt_cur

GO


GRANT EXECUTE ON [Daily_RestsWithNoResosYet] TO ExecuteOnlyRole

GO
