if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosActiveMonitorNLMapGeneration]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosActiveMonitorNLMapGeneration]
go

create procedure [dbo].[NagiosActiveMonitorNLMapGeneration] 
as

	set nocount on
	set transaction isolation level read uncommitted
	
	declare @result int
	declare @lookup_generateddt datetime
	declare @status    tinyint
	declare @message   varchar(100)
	
	set @result = 0
	
	exec dbo.DNGetNLMapGenerationDateTime  @Date=@lookup_generateddt OUTPUT	
	
	if (@lookup_generateddt is null)
		goto invoke_nagios;
		

	declare db_cursor cursor for
	select 		s.serverID, 
				ms.GeneratedDT
	from 		serversite ss
	inner join 	server s 
	on 			s.serverid = ss.serverid
	inner join 	sitetype st 
	on 			st.sitetypeid = ss.sitetypeid
	left join (select ServerID, siteTypeId, max(GeneratedDT) as GeneratedDT
				from MapFileStatus
				group by ServerID, SiteTypeID) ms on ss.serverid = ms.serverid
	where ss.sitetypeid in (207,208,209) -- ISAPIWeb_NA, ISAPIWeb_EU and ISAPIWeb_Asia
	and st.enabled = 1
	and s.active = 1
	
	declare @serverid int
	declare @generateddt datetime, @currentTimeThreshold  datetime
	
	open db_cursor
	fetch next from db_cursor  
	into @serverid, @generateddt

	if (@@fetch_status <> 0)
	begin
		set @result = -1  -- problem accessing records
		set @message = 'Error accessing Server, ServerSite, SiteType, MapFileStatus records' 
		goto exit_handler;
	end

	set @currentTimeThreshold = dateadd( "n", -30 , getdate()) ;  -- 30 minutes  threshold time	

	while @@fetch_status =0
	begin
		if (@generateddt is null)
		begin
			if (@currentTimeThreshold > @lookup_generateddt)
			begin
				set @result = -2   -- should have generated
				set @message = 'Initial map file not generated on serverid ' + cast(@serverid as varchar(10)) + '<br>'
			end 
		end	 else
		if (@generateddt <> @lookup_generateddt)
		begin
			if (@currentTimeThreshold > @lookup_generateddt and @generateddt < @currentTimeThreshold)
			begin 
				set @result = -3   -- haven't generated in a while
				set @message = 'Map file not generated on serverid ' + cast(@serverid as varchar(10)) + '<br>'
			end
		end 
		
		fetch next from db_cursor
		into @serverid, @generateddt
	end

exit_handler:
	close db_cursor
	deallocate db_cursor
invoke_nagios: 
	if (@result <> 0)
	begin
		set @status = 2   --Nagios Error status
	end else 
	begin
		set @status = 0   -- Nagios OK status
		set @message = 'NL Map Generation OK'
	end
		
	exec procNagiosActiveResponse @status, @message
GO

grant execute on [dbo].[NagiosActiveMonitorNLMapGeneration] to ExecuteOnlyRole
grant execute on [dbo].[NagiosActiveMonitorNLMapGeneration] to MonitorUser
GO
