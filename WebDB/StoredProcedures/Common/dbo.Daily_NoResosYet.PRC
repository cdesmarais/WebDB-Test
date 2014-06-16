if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_NoResosYet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_NoResosYet]
GO

CREATE proc dbo.Daily_NoResosYet
(
@rptID int
)

as 

set nocount on
set transaction isolation level read uncommitted

declare @virgin_count int

select @virgin_count = count(c.CustID)  
from Customer c 
where c.CustID not in (select c.CustID 
                          from Customer c
                          inner join reservation r
                          on r.CustID = c.CustID)


declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set	@strReport = 'Users w/ no Resos: ' + cast(@virgin_count as nvarchar(20)) + @vbnewline

insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)

                          
GO

GRANT EXECUTE ON [Daily_NoResosYet] TO ExecuteOnlyRole

GO
