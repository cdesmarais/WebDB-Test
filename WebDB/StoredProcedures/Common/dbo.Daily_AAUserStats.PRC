if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_AAUserStats]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_AAUserStats]
GO

CREATE PROCEDURE dbo.Daily_AAUserStats
(
@rptID int,
@strDateOffset int
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @AAResYest as integer
declare @AAResTotal as integer
declare @AARegYest as integer
declare @AADinerYest as integer


select @AARegYest = count(CallerID) from Caller  
where Caller.PositionID = 3 
and Caller.email not like '%@opentable.com' 
and datediff(d,Caller.createdate,getdate()- @strDateOffset) = 0


select @AADinerYest = count(CustID) from CallerCustomer 
inner join Caller on Caller.CallerID = CallerCustomer.CallerID 
where Caller.PositionID = 3 
and Caller.email not like '%@opentable.com' 
and datediff(d,CallerCustomer.createdate,getdate()- @strDateOffset) = 0 


declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set	@strReport = 'Total AA Registrations Yesterday: '  + cast(@AARegYest as nvarchar(20)) + @vbnewline + 
		'Total AA Diners created Yesterday: '  + cast(@AADinerYest as nvarchar(20)) + @vbnewline

insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)
GO

GRANT EXECUTE ON [Daily_AAUserStats] TO ExecuteOnlyRole

GO
