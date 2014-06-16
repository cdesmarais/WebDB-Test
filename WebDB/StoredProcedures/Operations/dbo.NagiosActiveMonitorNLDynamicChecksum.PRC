if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosActiveMonitorNLDynamicChecksum]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosActiveMonitorNLDynamicChecksum]
go

create procedure [dbo].[NagiosActiveMonitorNLDynamicChecksum] 
as

	set nocount on
	set transaction isolation level read uncommitted
	
	declare @status    tinyint
	declare @message   varchar(100)

	declare db_cursor cursor for
	select s.serverID, ss.dynamicchecksumlive
	from serversite ss
	inner join server s on s.serverid = ss.serverid
	inner join sitetype st on st.sitetypeid = ss.sitetypeid
	where ss.sitetypeid in (207,208,209) -- ISAPIWeb_NA, ISAPIWeb_EU and ISAPIWeb_Asia
	and st.enabled = 1
	and s.active = 1
	
	declare @serverid int, @result int
	declare @dynamicchecksum  nvarchar(50), @initial_dynamicchecksum   nvarchar(50)
	
	open db_cursor
	fetch next from db_cursor  
	into @serverid, @initial_dynamicchecksum

	if (@@fetch_status <> 0)
	begin
		set @result = -1  -- problem accessing records
		set @message = 'Error accessing Server, ServerSite, SiteType records' 
		goto exit_handler;
	end

	set @result = 0
	set @dynamicchecksum = @initial_dynamicchecksum

	while @@fetch_status =0
	begin
		if (@dynamicchecksum <> @initial_dynamicchecksum)
		begin
			set @result = -2 	-- dynamic checksum's don't match
			set @message = 'Dynamic checksum dont match' 
			goto exit_handler
		end
		
		fetch next from db_cursor
		into @serverid, @dynamicchecksum
	end

exit_handler:
	close db_cursor
	deallocate db_cursor
	
	if (@result <> 0)
	begin
		set @status = 2  -- Nagios Status Error
	end else 
	begin
		set @status = 0  -- Nagios Status OK
		set @message = 'WebISAPI Dynamic Checksum OK'
	end
		
	exec procNagiosActiveResponse @status, @message
GO

grant execute on [dbo].[NagiosActiveMonitorNLDynamicChecksum] to ExecuteOnlyRole
grant execute on [dbo].[NagiosActiveMonitorNLDynamicChecksum] to MonitorUser
go