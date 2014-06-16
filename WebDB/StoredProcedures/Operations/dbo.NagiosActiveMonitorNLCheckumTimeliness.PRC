if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosActiveMonitorNLCheckumTimeliness]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosActiveMonitorNLCheckumTimeliness]
go

create procedure dbo.NagiosActiveMonitorNLCheckumTimeliness (
	@ServerIPAddress	 NVARCHAR(50),
	@InstanceName 	 	NVARCHAR(100),
	@Interval			int    -- in minutes
)
as
	set nocount on
	set transaction isolation level read uncommitted


	DECLARE @SiteTypeID  int, @ServerID int, @Active  bit, @AcceptsTraffic bit, @result int
	DECLARE @UpdatedDT datetime	
	declare @status    tinyint
	declare @message   varchar(100)
	
	set @result = 0
	
	SELECT @ServerID = ServerID, @Active = Active, @AcceptsTraffic = AcceptsTraffic
	FROM [dbo].[Server]
	WHERE IPAddress = @ServerIPAddress
	
	if (@Active is null or @Active = 0)
		goto exit_handler;
		
	if (@AcceptsTraffic = 0)
		goto exit_handler;

	SELECT @SiteTypeID = SiteTypeID
	FROM [dbo].[SiteType]
	WHERE Instance = @InstanceName

	SELECT @UpdatedDt=UpdateDT 
	FROM [dbo].[ServerSite]
	WHERE ServerID = @ServerID AND SiteTypeID =@SiteTypeID
	
	if (@UpdatedDT is null)
	begin
		set @result = -1
		set @message = 'Checksum not generated on serverid ' + cast (@ServerID as varchar(10))
		goto exit_handler;
	end
	
	declare @LastCheckSumDateThreshold  datetime  
	set @LastCheckSumDateThreshold = dateadd( "n", @Interval * -2, getdate()) ;
	
	if (@UpdatedDT < @LastCheckSumDateThreshold)
	begin
		set @result = -2
		set @message = 'Checksum generation late on serverid ' + cast (@ServerID as varchar(10))
		goto exit_handler;
	end

exit_handler:
	if (@result <> 0)
	begin
		set @status = 2   -- Nagios Status Error
	end else 
	begin
		set @status = 0   -- Nagios Status OK
		set @message = 'WebISAPI Checksum Timeliness OK'
	end
		
	exec procNagiosActiveResponse @status, @message
GO


grant execute on [dbo].[NagiosActiveMonitorNLCheckumTimeliness] to ExecuteOnlyRole
grant execute on [dbo].[NagiosActiveMonitorNLCheckumTimeliness] to MonitorUser
go