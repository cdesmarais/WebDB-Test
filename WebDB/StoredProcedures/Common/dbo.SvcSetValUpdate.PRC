if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcSetValUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcSetValUpdate]
GO

CREATE PROCEDURE dbo.SvcSetValUpdate
@QueueID int, 
@SendAttempts int, 
@Successful bit
AS
	-- we don't care about the rowcount being returned
	SET NOCOUNT OFF
	
	-- in future if we have select statement, consider whether we want committed or non committed reads
	-- for now, non issue
	
	DECLARE		@UpdateDT DateTime
	SET			@UpdateDT = NULL
	
	-- 0 is success, 1 is failure
	-- if we fail don't mark the row as successful
    IF			@Successful = 0
	BEGIN		
		SET 	@UpdateDT = getdate()
    END
	
	UPDATE		SetValQueue
	SET			SendSuccessDT = @UpdateDT, 
				SendAttempts = @SendAttempts
	WHERE		QueueID = @QueueID
	
GO

GRANT EXECUTE ON [dbo].[SvcSetValUpdate] TO ExecuteOnlyRole

GO
