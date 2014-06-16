if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosActiveOTServiceInstanceCheck]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosActiveOTServiceInstanceCheck]
GO

CREATE PROCEDURE dbo.NagiosActiveOTServiceInstanceCheck
(
    @ExpectedOTServiceInstances int, 
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

select			@count = count(ss.sitetypeid)
from			ServerSite ss 
inner join		Server s 
on				ss.serverid = s.serverid 
inner join		SiteType st
on				ss.sitetypeid = st.sitetypeid
where			(s.Active = 1 or datediff(mi, ss.updatedt, getdate()) <= 30)
and				st.sitetypeId < 300
and				st.Service =1 
and				datediff(mi, ss.updatedt, getdate()) <= @StalenessMinutes


set @message = 'Expected: ' + CONVERT(varchar(50), @ExpectedOTServiceInstances) + 
		' Actual: ' + CONVERT(varchar(50), @count)
		
if(@count <> @ExpectedOTServiceInstances)
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

GRANT EXECUTE ON [NagiosActiveOTServiceInstanceCheck] TO ExecuteOnlyRole
GRANT EXECUTE ON [NagiosActiveOTServiceInstanceCheck] TO MonitorUser

GO
