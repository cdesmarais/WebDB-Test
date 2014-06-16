if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAgeRestStatusLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAgeRestStatusLog]
GO

CREATE PROCEDURE dbo.DNAgeRestStatusLog
AS

SET NOCOUNT ON

-- create temp table
CREATE TABLE #TempRestStatusLog
( 
RID int,
IsOnline bit,
StatusChangeDate datetime
)

declare @currTS datetime
set @currTS = current_timestamp

-- insert data into temp table.. get max status change date and get the status for that record
-- only look at records that are targeted for deletion
insert into #TempRestStatusLog(RID,IsOnline,StatusChangeDate) 
 	(select l.rid,l.isonline,l.statuschangedate 
  		from reststatuslog l 
   	inner join 
 	(select max(statuschangedate) as statuschangedate,rid 
  		from reststatuslog 
  		where datediff(dd,StatusChangeDate,@currTS) > 60
   		group by rid) maxstat 
	on maxstat.rid=l.rid and l.statuschangedate=maxstat.statuschangedate)

-- delete records older than 60 days (2 months)
Delete from reststatuslog where datediff(dd,StatusChangeDate,@currTS) > 60

-- add back the last know record...
insert into reststatuslog(RID,IsOnline,StatusChangeDate)
select RID,IsOnline,StatusChangeDate from #TempRestStatusLog

-- drop table..
drop table #TempRestStatusLog
GO

GRANT EXECUTE ON [DNAgeRestStatusLog] TO ExecuteOnlyRole

GO
