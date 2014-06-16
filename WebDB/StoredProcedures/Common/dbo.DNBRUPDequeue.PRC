if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNBRUPDequeue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNBRUPDequeue]
GO


CREATE PROCEDURE dbo.DNBRUPDequeue
(
	 @BRUPQueueID int
	,@Processed bit
	,@LastSequenceIdProcessed int
	,@QDeleteOn int
)
As

	--*****************************
	--** IF we delete as we go and record is completely processed
	--** Delete the record from all tables
	--*****************************
	if (@Processed = 1 and @QDeleteOn = 1)
	begin
		begin transaction
			-- Delete from processed record it may contain a record that was previously partialy processed
			delete BRUPQueueProcessed where BRUPQueueID = @BRUPQueueID
			-- Delete the master record
			delete BRUPQueue where BRUPQueueID = @BRUPQueueID
		commit
		-- Exit nothing left to do
		return
	end
	

	--******************************
	--** If code has gotten here then this is not a case where a delete on the fly is required
	--** Marks a batch 
	--** as processed
	--******************************

	declare		 @error			int
				,@rc			int
				,@RowCount		int
				,@errorstr		nvarchar(100)

	set			@rc				= 0			-- assume success
	begin tran	DequeueTran

	-- if batch was attempted / already in queue then update it
	if exists (select BRUPQueueID from BRUPQueueProcessed where BRUPQueueId = @BRUPQueueID)
	begin

		-- Dequeue binary message from BRUPQueue
		-- (mark it as processed by updating row  
		-- in BRUPQueueProcessed table
		UPDATE		 BRUPQueueProcessed
		SET			 LastSequenceIdProcessed = @LastSequenceIdProcessed
					,Processed = @Processed
		WHERE		BRUPQueueID = @BRUPQueueID

		select		 @rowCount = @@rowcount
					,@error	   = @@error

		if @rowCount != 1 
		or @error != 0
		  begin
			set	 @errorstr = 'Failed to update BRUPQueueProcessed BRUPQueueID: ' + cast(@BRUPQueueID as nvarchar) + ' with values: SequenceID: ' + cast(@LastSequenceIdProcessed as nvarchar) + ' Processed: ' + cast(@Processed as nvarchar)
			goto general_error
		  end

	end
	else
	begin


		-- Dequeue binary message from BRUPQueue
		-- (mark it as processed by adding row  
		-- in BRUPQueueProcessed table

		INSERT INTO BRUPQueueProcessed
		(BRUPQueueID, LastSequenceIdProcessed, Processed)
		VALUES (
					 @BRUPQueueID
					,@LastSequenceIdProcessed
					,@Processed
				)

		select		 @rowCount = @@rowcount
					,@error	   = @@error

		if @rowCount != 1 
		or @error != 0
		  begin
			set	 @errorstr = 'Failed to add BRUPQueueID: ' + cast(@BRUPQueueID as nvarchar) + ' to BRUPQueueProcessed. SequenceID: ' + cast(@LastSequenceIdProcessed as nvarchar) + ' Processed: ' + cast(@Processed as nvarchar)
			goto general_error
		  end
		
	end


	-- success
	commit tran DequeueTran
	return @rc



general_error:
	rollback tran DequeueTran
	set @rc = -1
	RAISERROR(@errorstr,17,1)
	return @rc

GO

GRANT EXECUTE ON DNBRUPDequeue TO ExecuteOnlyRole

GO
