if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAgeRestStatusTrackLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAgeRestStatusTrackLog]
GO

CREATE PROCEDURE dbo.DNAgeRestStatusTrackLog
AS

SET NOCOUNT ON

-- create temp table
CREATE TABLE #TempRestStatusTrackLog
( 
RID int,
StatusChangeDateTS datetime,
UserID nvarchar(100),
NewStatus int
)

declare @currTS datetime
set @currTS = current_timestamp

-- insert data into temp table.. get max status change date and get the status for that record
-- only look at records that are targeted for deletion
insert into #TempRestStatusTrackLog(RID,StatusChangeDateTS,UserID,NewStatus)  
	(select l.rid,l.statuschangedatets,l.UserID,l.NewStatus 
		from RestStatusTrackLog l 
		inner join 
	(select max(statuschangedatets) as statuschangedatets,rid 
		from RestStatusTrackLog 
		where datediff(dd,StatusChangeDateTS,@currTS) > 60
		group by rid) maxstat 
	on maxstat.rid=l.rid and l.statuschangedatets=maxstat.statuschangedatets)

-- delete records older than 60 days (2 months)
Delete from RestStatusTrackLog where datediff(dd,StatusChangeDateTS,@currTS) > 60

-- add back the last know record...
insert into RestStatusTrackLog(RID,StatusChangeDateTS,UserID,NewStatus)
select RID,StatusChangeDateTS,UserID,NewStatus from #TempRestStatusTrackLog



-- drop table..
drop table #TempRestStatusTrackLog
GO

GRANT EXECUTE ON [DNAgeRestStatusTrackLog] TO ExecuteOnlyRole

GO
