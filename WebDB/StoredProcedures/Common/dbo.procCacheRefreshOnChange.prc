if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procCacheRefreshOnChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procCacheRefreshOnChange]
go


create  Procedure [dbo].[procCacheRefreshOnChange]
as
/*
	This procedure queries the available cache sets
	and calls an external procedure to calculate the
	check sum of the objects that the cache set is dependant
	upon.  The procedure then updates the cache set record
	with the new checksum if it's different.
*/
declare @CacheKey		nvarchar(50), 
		@CheckSum		int, 
		@SetsUpdated	nvarchar(4000),
		@ProcName		nvarchar(128),
		@error			int,
		@rowcount		int

-- Used to id the proc in logs
set @ProcName = OBJECT_NAME(@@PROCID)
set @SetsUpdated = ''
		
declare csrCacheKeys cursor for
	select CacheRefreshOnChangeID
	from CacheRefreshOnChange

open csrCacheKeys
fetch next from csrCacheKeys
into @CacheKey

while @@fetch_status = 0
begin
	exec procChecksumForCacheSet @CacheKey, @CheckSum output, 0
	select @error = @@error
	if @error <> 0
		goto ErrHandler

	begin
		update		CacheRefreshOnChange
		set			UpdateTS = getdate()
					,LastChecksum = @CheckSum
		where		CacheRefreshOnChangeID = @CacheKey
		and			LastChecksum != @CheckSum
		
		select @error = @@error, @rowcount = @@rowcount
		if @error <> 0
			goto ErrHandler
		
		if @rowcount > 0
			set @SetsUpdated = @SetsUpdated + @CacheKey + ','
	end
		
	fetch next from csrCacheKeys
	into @CacheKey
end
close csrCacheKeys
deallocate csrCacheKeys

--If we've updated any checksums log the sets that were done
if len(@SetsUpdated) > 0
begin
	declare @LogMsg nvarchar(4000)
	set @LogMsg = 'Updated the checksums for the following keys: ' + @SetsUpdated
	 
	exec dbo.DNErrorAdd
	@ErrorID =			9030,
	@ErrStackTrace =	@ProcName,
	@ErrMsg =			@LogMsg,
	@ErrSeverity =		2
end	

select @error = @@error
	if @error <> 0
	goto ErrHandler
	
--success
goto TheEnd

--Log the error and then cause the
--job controlling this proc to flag
--an alert in NAGIOS
ErrHandler:
	close csrCacheKeys
	deallocate csrCacheKeys

	exec dbo.DNErrorAdd
	@ErrorID =			9030,
	@ErrStackTrace =	@ProcName,
	@ErrMsg =			@error,
	@ErrSeverity =		2
	
return(-1)

TheEnd:
return (0)

go

grant execute on [procCacheRefreshOnChange] TO ExecuteOnlyRole
go
	