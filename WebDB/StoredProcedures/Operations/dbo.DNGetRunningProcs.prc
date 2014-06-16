
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetRunningProcs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetRunningProcs]
GO


-- Note this should run as 'sa'
Create procedure dbo.DNGetRunningProcs

as

set transaction isolation level read uncommitted
set nocount on

declare	@cmd nvarchar(1000)
declare	@status nvarchar(20)

Declare @NumberofSeconds int
select	@NumberofSeconds = isnull(ValueInt, 300)
from	valuelookup 
where	LType='NAGIOS_LONGRUNNINGPROCS' 
and		LKey = 'Default'
							
Declare @procs nvarchar(4000)
Set @procs = ''

declare @buf nvarchar(1000) ,
	@id int ,
	@spid int ,
	@maxSpid int
	create table #spid (spid int, command nvarchar(1000) null)
	create table #temp (x nvarchar(100), y int, s nvarchar(1000), id int identity (1,1))
	create table #spids (spid int)
	
	insert	#spids 
	select 	distinct spid 
	from 	master..sysprocesses 
	where 	blocked <> 0
	or	upper(cmd)    not in 	(
		'AWAITING COMMAND'
		,'MIRROR HANDLER'
		,'LAZY WRITER'
		,'CHECKPOINT SLEEP'
		,'RA MANAGER'
		,'LOG WRITER'
					)
	or lower(status) <> 'sleeping'


	select 	@spid = 50 ,
		@maxSpid = max(spid)
	from	#spids
	
	while @spid < @maxSpid
	begin
		select	@spid = min(spid) from #spids where spid > @spid
		
		select @cmd = 'dbcc inputbuffer (' + convert(nvarchar(10),@spid) + ')'
		
		delete #temp
		
		insert #temp
		exec (@cmd)

		--print 		@cmd

		select 	@id = 0 ,
			@buf = ''
		select @buf = @buf + replace(replace(s,char(10),'|'),char(13),'|')

		from #temp

		--select * from #temp

		insert 	#spid
		select	@spid, @buf
	end
	
	Declare @DateMade datetime
	Set @DateMade = current_timestamp
	
	Declare @Count int
	Set @Count = 0


	select 	@procs = @procs + '<br>' + replace(#spid.command,'||','') + ' Ran for ' +
		cast(datediff(ss,s.last_batch,getdate()) as nvarchar(20)) + ' seconds'
		, @Count = @Count + 1
	

	--	LastBatch	= convert(nvarchar(23),s.last_batch,121) ,
	--	SecondsRunning	= datediff(ss,s.last_batch,getdate()),
	--	buffercmd	= replace(#spid.command,'||','')
	from	#spid ,
		master..sysprocesses s
	where	s.spid = #spid.spid 
        --s.last_batch periodically contains an invalid value that will cause
        --datediff to throw a runtime overflow error (happens when value returned
        --is larger than 68 years in seconds).  we'll use jan 1st, 2006 as a starting
        --point since procs will not ever be running this long.
        and     s.last_batch > '1/1/2006' 
	and 	(ecid = 0 or isnumeric(@status) = 1)
	and 	s.status <> 'background'
	--These procs are expected to run longer than 300 secs at times and are being filtered to avoid false alerts
	 and datediff(ss,s.last_batch,getdate()) > 
		ISNULL (
				(	select ValueInt 
					from	valuelookup 
					where	LType='NAGIOS_LONGRUNNINGPROCS' 
					and		#spid.command like '%'+ Lkey + '%'
				), 
				@NumberofSeconds
			)
	order by convert(int,s.spid) desc

	drop table #spid
	drop table #spids
	drop table #temp

	if @procs <> ''
	BEGIN
		Set @procs = 'Long Running Stored Procs: ' + @procs
		
		Declare @procStatus int
		Set @procStatus = 2
		If @Count = 1 and left(@procs,53) = 'Long Running Stored Procs: <br>exec sp_trace_getdata'
		BEGIN
			Set @procStatus = 1
		END
		
		Exec dbo.DNNagiosWriteStatus @NagiosTaskID = 4, 
			@Host = null, 
			@Status = @procStatus, 
			@UpdateDT = @DateMade, 
			@Msg = @procs
	END
	else
	BEGIN

		Exec dbo.DNNagiosWriteStatus @NagiosTaskID = 4, 
			@Host = null, 
			@Status = 0, 
			@UpdateDT = @DateMade, 
			@Msg = 'Stored Procs OK'
	END	
GO


GRANT EXECUTE ON [DNGetRunningProcs] TO ExecuteOnlyRole

GO
