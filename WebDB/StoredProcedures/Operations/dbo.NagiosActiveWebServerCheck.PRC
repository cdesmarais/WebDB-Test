if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosActiveWebServerCheck]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosActiveWebServerCheck]
GO

CREATE PROCEDURE dbo.NagiosActiveWebServerCheck
(
    @Expected int, 
	@StalenessMinutes int
)
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--****************
-- Step 1: Determine if more than the expected count of OTService sitetypeid is running in the serversite table using
-- Active = 1 and no more than 15 mins (@stalenessminutes) old
--****************

declare @status int
declare @message nvarchar(200)
declare @count int

set @count = 
(
select			COUNT(distinct s.ServerID)
from			ServerSite ss 
inner join		Server s 
on				ss.serverid = s.serverid 
inner join		SiteType st
on				ss.sitetypeid = st.sitetypeid
where			(s.Active = 1 or datediff(mi, ss.updatedt, getdate()) <= 30)
and				st.SiteTypeID between 101 and 110
and				s.AcceptsTraffic = 1
and				datediff(mi, ss.updatedt, getdate()) <= 20
)

set @message = 'WebServers Expected: ' + CONVERT(varchar(50), @Expected) + 
		' Actual: ' + CONVERT(varchar(50), @count)
		
if(@count <> @Expected)
begin
	set @status = 2
	set @message = 'MISMATCH '+ @message
end
else
begin
	set @status = 0
end

exec procNagiosActiveResponse @Status, @message

		
GO

GRANT EXECUTE ON [NagiosActiveWebServerCheck] TO ExecuteOnlyRole
GRANT EXECUTE ON [NagiosActiveWebServerCheck] TO MonitorUser

GO
