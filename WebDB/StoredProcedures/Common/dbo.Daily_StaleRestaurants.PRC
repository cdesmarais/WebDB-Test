if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_StaleRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_StaleRestaurants]
GO


CREATE proc dbo.Daily_StaleRestaurants
@rptID int
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select rt.RName as rest_name
		,ma.MetroAreaName as city
		,min(DATEDIFF(day, r.DateMade, getdate())) AS no_of_days    
	from Reservation r    
	inner join	restaurantVW rt
	on			rt.RID = r.RID    
	inner join	NeighborhoodAVW n 
	on			n.NeighborhoodID = rt.NeighborhoodID    
	and			n.LanguageID = rt.LanguageID
	inner join	MetroAreaAVW ma
	on			ma.MetroAreaID = n.MetroAreaID    
	and			ma.LanguageID = rt.LanguageID
	where r.RStateID in  (1,2,5,6,7)   
	and rt.RestStateID = 1   
	and ma.MetroAreaID <> 1   
	group by rt.RName
	, ma.MetroAreaName   
	having min(DATEDIFF(day, r.DateMade, getdate())) > 6   
	order by no_of_days desc

--Format report
declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'Days since last reso made (at least 7 days): ' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)

--cursor
	Declare @rest_name nvarchar(255)
	Declare @city nvarchar(255)
	Declare @no_of_days nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @rest_name, @city, @no_of_days

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @Rest_name + ' - ' + @city + ' : ' + @no_of_days + ' days' + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @rest_name, @city, @no_of_days
	END
	CLOSE rpt_cur

GO


GRANT EXECUTE ON [Daily_StaleRestaurants] TO ExecuteOnlyRole

GO
