if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[WLog_Clean]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[WLog_Clean]
GO



CREATE Procedure dbo.WLog_Clean
(@cutoff datetime =NULL)
As
--*****************************************************************************
--** WLog_Clean
--**
--** Deletes data from the WLog and WLogMsg table 
--** that is greater than 60 days old
--**
--** Intended to be called as a nightly job
--*****************************************************************************


SET NOCOUNT ON


begin
	declare @id1 as int
	declare @id2 as int
	declare @del_id as int

	declare @LogID int
	declare @rowcount int
	
	if @cutoff is null set @cutoff= getdate() - 60

	--*************************
	--**Find starting point for purge
	--**Take advantage of primary key and chronological insert of data to find a small logid that contains the deletion batch
	--*************************
	select @LogID = min(WLogID) + 100000 from WLogVW
	while exists(select WLogID from WLogVW where WLogID = @LogID and createdt < @cutoff)
	begin
	      set @LogID = @LogID + 100000
	end

	--** SPECAL CASE
	--** don't use primary key trick until after the PK born date
	--** data before this date was not inserted chronologicaly so cannot use PK trick
	if (@cutoff < '2006-08-11')
	begin
		--Table scan for min ID
		select @LogID = max(WLogID) from WLogVW where createdt < '2006-08-11'
	end
	--** SPECAL CASE (END) TODO: Delete this case after 60 days after aug 1


    --Purge in batches
	set @rowcount  = 1
	SET ROWCOUNT 50000
	while @rowcount > 0
	begin
		Begin Transaction
		-- Delete records that are older than 60 days in batches
	     delete WLogVW where WLogID <  @LogID and createdt < @cutoff
	     set @rowcount = @@rowcount
		Commit Transaction
	end



	-- Find message Ids to delete
	select @id1 = min(InWLogMsgID)
	from WLogVW 
	where WLogID between @LogID and @LogID + 100000  -- Trick to quickly find the last message logged
	      and InWLogMsgID >= 100

	select @id2 = min(OutWLogMsgID)
	from WLogVW 
	where WLogID between @LogID and @LogID + 100000  -- Trick to quickly find the last message logged
		  and OutWLogMsgID >= 100

	-- Set the Del ID to smallest non-reserved id in use by a WLog record
	if (@id1 < @id2)
		set @del_id = @id1 
	else
		set @del_id = @id2 


	--************************
	--** Lookup actual log Table
	--************************
	declare @tableName varchar(200)
	select @tableName = dbo.fGetLogDBTable('WLog') 

	--**Disable FK checks
	exec ('alter table ' + @tableName + ' NoCheck constraint FK_WLog_InWlogMsgID')
	exec ('alter table ' + @tableName + ' NoCheck constraint FK_WLog_OutWlogMsgID')

	-- Delete corresponding WLogMsg Records
        --Purge in batches
	set @rowcount  = 1
	SET ROWCOUNT 10000
	while @rowcount > 0
	begin
		Begin Transaction
	      delete WLogMsgVW where WLogMsgID < @del_id and WLogMsgID >= 100
	      set @rowcount = @@rowcount
		Commit Transaction
	end

	
	--**Enable FK checks
	exec ('alter table ' + @tableName + ' Check constraint FK_WLog_InWlogMsgID')
	exec ('alter table ' + @tableName + ' Check constraint FK_WLog_OutWlogMsgID')
	
end

	if @@ERROR <> 0
		goto error

	Return(0)

error:
	RETURN('WLog_Clean FAILED: ' + cast(@@error as nvarchar))


GO

GRANT EXECUTE ON [WLog_Clean] TO ExecuteOnlyRole

GO
