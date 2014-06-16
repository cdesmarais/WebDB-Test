if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ComingRestaurantsByMetroArea]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ComingRestaurantsByMetroArea]
GO

create proc dbo.Daily_ComingRestaurantsByMetroArea
(
@rptID int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select ma.MetroAreaName as CityName
		,count(r.RID) as RestCount  
	from RestaurantVW r
	inner join	neighborhoodAVW n
	on			n.NeighborhoodID = r.NeighborhoodID  
	and			n.LanguageID = r.LanguageID
	inner join	MetroAreaAVW ma
	on			n.MetroAreaID = ma.MetroAreaID 
	and			r.LanguageID = ma.LanguageID
	where r.RestStateID in(2,3) 
	and ma.MetroAreaID  <> 1  
	group by ma.MetroAreaName 
	order by RestCount desc



--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Coming Soon by Metro Area: ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)


--cursor
	Declare @CityName nvarchar(255)
	Declare @RestCount nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @CityName, @RestCount

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @CityName + ' : ' + @RestCount + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @CityName, @RestCount
	END
	CLOSE rpt_cur

GO


GRANT EXECUTE ON [Daily_ComingRestaurantsByMetroArea] TO ExecuteOnlyRole

GO
