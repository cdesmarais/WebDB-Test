if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalPoints]
GO

CREATE proc dbo.Daily_TotalPoints
(
@rptID int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare @points_total int

select @points_total = sum(points) 
from Customer
where email not like '%@opentable.com'
and email not like '%@vertigosoftware.com'
and email not like 'tomh@logigear.com'
and email not like 'tomr@logigear.com'
and email not like 'd_r_king@yahoo.com'
and email not like 'merrimanp@email.msn.com'
and email not like 'tim@sunflowercapital.com'

declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)


set @strReport = @vbnewline + 'Total points awarded: ' + cast(@points_total as nvarchar(20)) + @vbnewline
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

GO

GRANT EXECUTE ON [Daily_TotalPoints] TO ExecuteOnlyRole

GO
