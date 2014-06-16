if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_UsersByMetroAreaYesterday]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_UsersByMetroAreaYesterday]
GO

create proc dbo.Daily_UsersByMetroAreaYesterday 
(
@rptID int,
@strDateOffset int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare rpt_cur CURSOR LOCAL READ_ONLY STATIC FOR
	select count(c.CustID) as UserCount
		,ma.MetroAreaName as MetName 
	from Customer c
	inner join MetroAreaVW ma
	on ma.MetroAreaID = c.MetroAreaID
	where ma.MetroAreaID <> 1 
	and c.email not like '%@opentable.com' 
	and datediff(d,c.CreateDate,getdate()- @strDateOffset) = 0
	group by ma.MetroAreaName order by UserCount desc


declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = @vbnewline + 'New Users by Metro Area: (yesterday)' + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 0, @strReport)

--cursor
	Declare @UserCount nvarchar(255)
	Declare @MetName nvarchar(255)
	Declare @i int

	set @i = 0
	
	OPEN rpt_cur
	FETCH NEXT FROM rpt_cur 
	INTO @UserCount, @MetName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @i = @i + 1
		set @strReport = @MetName + ' : ' + @UserCount + @vbnewline
		insert into DailyReport (reportid, linenum, txt) values(@rptID, @i, @strReport)		

		FETCH NEXT FROM rpt_cur 
		INTO @UserCount, @MetName
	END
	CLOSE rpt_cur

GO

GRANT EXECUTE ON [Daily_UsersByMetroAreaYesterday] TO ExecuteOnlyRole

GO
