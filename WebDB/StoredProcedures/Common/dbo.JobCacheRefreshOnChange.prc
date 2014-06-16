if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCacheRefreshOnChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCacheRefreshOnChange]
go


create  Procedure [dbo].[JobCacheRefreshOnChange]
as

	-- Wrapper proc for procCacheRefreshOnChange
	-- This proc will raise errors to trigger NAGIOS
	
	set nocount on
	set transaction isolation level read uncommitted 

	declare  @rc int
			,@error int
	
	exec @rc = procCacheRefreshOnChange
		
	select @error = @@error
	if @error != 0 
	begin
		raiserror('CacheSet checksums not updated, procCacheRefreshOnChange raised an error',16,1) 
		return
	end
	
	-- NOTE: these return codes are defined
	if @rc = 0
	begin
		-- success, go ahead and exit
		return
	end
	else if @rc = -1
	begin
		raiserror('CacheSet checksums not updated.  Encountered error updating checksums',16,1) 
		return
	end
	else 
	begin
		raiserror('CacheSet checksums not updated..  unknown error',16,1) 
		return
	end
	


go

grant execute on [JobCacheRefreshOnChange] TO ExecuteOnlyRole
go
