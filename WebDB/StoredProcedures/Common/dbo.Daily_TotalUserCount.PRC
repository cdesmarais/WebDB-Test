if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalUserCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalUserCount]
GO



CREATE PROCEDURE dbo.Daily_TotalUserCount
(
@rptID int,
@strDateOffset int
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @Members as integer
declare @Anonymous as integer

--OT Members
SELECT @Members = COUNT(Customer.CustID) 
FROM Customer 
where metroareaid <> 1
	AND DATEDIFF(d,createdate,getdate()-@strDateOffset) >=0

-- Total Anonymous
SELECT @Anonymous = COUNT(CustID)
FROM Customer
WHERE ConsumerType = 8
	AND DATEDIFF(d,createdate,getdate()-@strDateOffset) >=0


declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = ('Total Members: ') + cast(@Members as nvarchar(20)) + @vbnewline +
	'Total Anonymous Users: ' + cast(@Anonymous as nvarchar(20)) + @vbnewline

insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)


GO

GRANT EXECUTE ON [Daily_TotalUserCount] TO ExecuteOnlyRole

GO
