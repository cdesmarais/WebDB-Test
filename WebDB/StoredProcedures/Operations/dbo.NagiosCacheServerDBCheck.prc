if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosCacheServerDBCheck]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosCacheServerDBCheck]
GO

CREATE Procedure [dbo].[NagiosCacheServerDBCheck]
As

-- 
-- This proc is used to generate a Nagios alert/warning 
-- if the cache server hasn't written to the database in over 90 seconds

SET        NOCOUNT ON
SET        TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE		@MaxAge						int
DECLARE    @Status						TINYINT
DECLARE    @Message						VARCHAR(1000)

set @MaxAge = 90
set @Message = ''

select top 100 CacheLogID, CacheLogDate, Source 
into #temp
from CacheServerStats
order by 1 desc


select		s.ServerName, 
			DATEDIFF(SS, MAX(CacheLogDate), getdate())  Age
into		#CacheStatus			
from		Server s
left join	#temp t
on			t.source = s.ServerName
inner join	CacheServer cs
on			s.ServerID = cs.ServerID
where		s.Active = 1
group by	s.ServerName


if exists (select * from #CacheStatus where Age is null or Age > @MaxAge)
begin
	select @Message = @Message  
					+ ServerName 
					+ ' Age of last write Sec ' 
					+ Convert(varchar,Age)
					+ '\n'
	from	#CacheStatus
	where	Age is null or Age > @MaxAge
	
	set		@status = 2
end
else
begin
	select @Message = @Message  
					+ ServerName 
					+ ' Age of last write Sec ' 
					+ Convert(varchar,Age)
					+ '\n'
	from	#CacheStatus

	set		@status = 0
end

exec procNagiosActiveResponse @Status, @Message

GO

GRANT EXECUTE ON [NagiosCacheServerDBCheck] TO ExecuteOnlyRole
GRANT EXECUTE ON [NagiosCacheServerDBCheck] TO MonitorUser

GO

