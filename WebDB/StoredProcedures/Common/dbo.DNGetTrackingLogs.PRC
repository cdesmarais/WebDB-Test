if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetTrackingLogs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetTrackingLogs]
GO


CREATE PROCEDURE dbo.DNGetTrackingLogs
 (
  @RID int,
  @StartTime datetime,
  @EndTime datetime
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

--***TODO: EV: Consider revising proc and moving it to LogDB (7/18/2006)

	select @rid RID, 'CacheServer: ' + source as Method,
	'' as RemoteAddress, CacheLogDate as LogDate, Details as Query, '' as OutQuery,
	CacheLogID as SortID, '' as ElapsedMS, '' as Status
	from cacheservermessagelog
	where details like '%('+cast(@rid as nvarchar(10))+')%'
	and CacheLogDate > @StartTime and CacheLogDate < @EndTime
union
	Select RID, '3.1: Ping' as Method, RemoteAddress, DateEntered as LogDate, QueryString as Query, '' as OutQuery,
	0 as SortID, '' as ElapsedMS, '' as Status
	from erbpinglog where rid = @RID  and DateEntered > @StartTime and DateEntered < @EndTime
union
	Select RID, '3.1: '+Method as Method, 'Website' as RemoteAddress, DateEnterred as LogDate, '' as Query, '' as OutQuery,
	0 as SortID, '' as ElapsedMS, '' as Status
	from erbconnectionlog where rid = @RID and Method not in ('u.asp','c.asp')
	and DateEnterred > @StartTime and DateEnterred < @EndTime
union
	Select RID, '3.1: Failed Make' as Method, 'Website' as RemoteAddress,
	failtime as LogDate, ('For Party of ' + cast(PartySize as nvarchar(4)) + ' on ' + cast(resdatetime as nvarchar(20))) as Query, '' as OutQuery,
	LogID as SortID, '' as ElapsedMS, '' as Status
	from logfailedResos where rID = @RID
	and failtime > @StartTime and failtime < @EndTime
union
	Select RID, '[' + SrcIPAddress + '] ' + 'Authentication Network Address Log' as Method, 
	substring(Details,CHARINDEX('WAN IP:',Details)+7,CHARINDEX(' /',Details)-(CHARINDEX('WAN IP:',Details)+7)) + 
	' [' + ReportedNetworkAddress + ']' as RemoteAddress,
	LogDate as LogDate, Details as Query, '' as OutQuery,
	LogID as SortID, '0' as ElapsedMS, 
	(case 
		when AuthSuccess = 0 then 'Not Authenticated'				
		when AuthSuccess = 1 then 'Authenticated'			
		else '' end
	) as Status
	from AuthNetworkAddressLog where rID = @RID
	and LogDate > @StartTime and LogDate < @EndTime
union
	select RID, '['+IPServer + '] ' + Type + 
				(case when outm.msg like 'User-Agent: OpenTable Production Website%' then ' [PROD String]' else '' end)
				+ ' - ' + FuncEntryPt COLLATE DATABASE_DEFAULT as Method,
				IPErb as RemoteAddress, CreateDT as LogDate,
				coalesce(m.MSG, 'NULL') COLLATE DATABASE_DEFAULT as Query,
				coalesce(outm.MSG, 'NULL') COLLATE DATABASE_DEFAULT as OutQuery,
				coalesce(nullif(w.InWLogMsgID, 0), w.OutWLogMsgID) as SortID,
				ElapsedMS, 
				(case 
					when status = 0 then 'Success'				
					when status = 1 then 'Error'				
					when status = 2 then 'Time Out'				
					when status = 3 then 'No Connect'				
					else '' end
				) as Status
	from WLogVW w
	inner join WLogTypeVW t on t.WLogType = w.WLogType
	inner join WLogMsgVW m on w.InWLogMsgID = m.WLogMsgID
	inner join WLogMsgVW outm on w.OutWLogMsgID = outm.WLogMsgID
	where rID = @RID
	and CreateDT > @StartTime and CreateDT < @EndTime

order by LogDate, SortID, Query, OutQuery
GO


GRANT EXECUTE ON [DNGetTrackingLogs] TO ExecuteOnlyRole

GO
