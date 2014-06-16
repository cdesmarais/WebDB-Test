if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosActiveVersionCheck]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosActiveVersionCheck]
GO

CREATE PROCEDURE dbo.NagiosActiveVersionCheck
(
	@ServerIP nvarchar(100), 
	@SiteType nvarchar(100),  
	@StalenessMinutes int
)
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--****************
--** Step1: Establish Consensus
--** NOTE: Becuase Version number is region wide, there is no where clause
--****************
declare @ConsensusVersion as nvarchar(200)
select top 1 
			@ConsensusVersion = substring(VersionnumberLive, 0, charindex('.',VersionnumberLive))
from		ServerSite ss 
inner join	Server s
on			s.ServerID = ss.ServerID
where		s.Active = 1  -- Only consider Active Servers for consensus
and			datediff(hour, ss.UpdateDT, getdate()) < 24 -- only consider data that is less than 24 hours old in the serversite table
group by	substring(VersionnumberLive, 0, charindex('.',VersionnumberLive))
order by	count(1) desc, substring(VersionnumberLive, 0, charindex('.',VersionnumberLive))


--****************
--** Step2: For a given server / site
--**		validate against consensus
--****************
declare @status int
declare @message nvarchar(200)

select			@status  = (case	
					when  substring(VersionnumberLive, 0, charindex('.',VersionnumberLive)) = @ConsensusVersion then 0
					else 2 end
				) ,
				@message = 'Actual: ' + substring(VersionnumberLive, 0, charindex('.',VersionnumberLive))  
						+ ' Expected: ' + @ConsensusVersion
from			ServerSite ss 
inner join		Server s 
on				ss.serverid = s.serverid 
inner join		SiteType st
on				ss.sitetypeid = st.sitetypeid
where 			s.IPAddress = @ServerIP
and				st.Instance = @SiteType
and				datediff(mi, ss.updatedt, getdate()) <= @StalenessMinutes

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

GRANT EXECUTE ON [NagiosActiveVersionCheck] TO ExecuteOnlyRole
GRANT EXECUTE ON [NagiosActiveVersionCheck] TO MonitorUser

GO
