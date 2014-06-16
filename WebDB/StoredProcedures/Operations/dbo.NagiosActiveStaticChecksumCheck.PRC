if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosActiveStaticChecksumCheck]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosActiveStaticChecksumCheck]
GO

CREATE PROCEDURE dbo.NagiosActiveStaticChecksumCheck
(
	@ServerIP nvarchar(100), 
	@SiteType nvarchar(100), 
	@StalenessMinutes int
)
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--****************
--** Step1: Establish Consensus: Dynamic Checksum
--****************
declare @Consensus as nvarchar(200)
select top 1 
			@Consensus = StaticChecksumExpected 
from 		ServerSite ss
inner join 	Server s
on			s.ServerID = ss.ServerID
inner join	SiteType st
on			st.SiteTypeID = ss.SiteTypeID
where		s.Active = 1  -- Only consider Active Servers for consensus
and			datediff(hour, ss.UpdateDT, getdate()) < 24 -- only consider data that is less than 24 hours old in the serversite table
and 		st.Instance = @SiteType
group by	StaticChecksumExpected 
order by	count(1) desc, StaticChecksumExpected



declare @status int
declare @message nvarchar(200)

select		@status = (case	
						when ss.StaticChecksumLive = StaticChecksumExpected and ss.StaticChecksumLive = @Consensus then 0 
						else 2 end
						),
			@message  = 'Actual: ' + ss.StaticChecksumLive + ' Expected: ' + ss.StaticChecksumExpected + ' Consensus: ' + @Consensus
from		ServerSite ss
inner join 	Server s
on			s.ServerID = ss.ServerID
inner join	SiteType st
on			st.SiteTypeID = ss.SiteTypeID
where		s.IPAddress = @ServerIP
and			st.Instance = @SiteType
and			datediff(mi, ss.updatedt, getdate()) <= @StalenessMinutes

if @@ROWCOUNT = 0
begin
	--***********************
	--** If we got here then either the ServerSite doesn't exist (hasn't registered)
	--** or the data is stale
	--***********************
	select  @status = 2,
			@message = 'Data Could Not Be Found Or is Stale'
end

--** Output Status and message
--** Note Currently a bug in nagios; success must only be 0 (no message)
select  @status as Status,
		(case when @status = 0 then '' else replace(@message, ' ', '_') end) as ErrorMessage
		
GO

GRANT EXECUTE ON [NagiosActiveStaticChecksumCheck] TO ExecuteOnlyRole
GRANT EXECUTE ON [NagiosActiveStaticChecksumCheck] TO MonitorUser
GO
