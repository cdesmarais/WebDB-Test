if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetRefreshOnChangeTimestamps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetRefreshOnChangeTimestamps]
go


create  Procedure [dbo].[DNGetRefreshOnChangeTimestamps]
as
/*
Selects out the data from the CacheRefreshOnChange table
for comparison in the web cache manager.  If the web cache
has any cache items older than the corresponding cache set
id, it will rebuild the particular cache item.
*/
select	CacheRefreshOnChangeID
		,UpdateTS
		,LastChecksum 
from	CacheRefreshOnChange
go

grant execute on [DNGetRefreshOnChangeTimestamps] TO ExecuteOnlyRole
go
	