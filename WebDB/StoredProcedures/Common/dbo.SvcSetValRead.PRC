if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcSetValRead]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcSetValRead]
GO

CREATE PROCEDURE dbo.SvcSetValRead
@MaxSendRetryAttempts int
AS
	-- we don't care about the rowcount being returned
	SET NOCOUNT OFF
	-- we need dirty reads to not lock restaurant table
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SELECT			svq.RID, 
					svq.[Key], 
					svq.Val, 
					svq.CreateDT, 
					svq.Reason, 
					svq.SendAttempts, 
					svq.QueueID
	FROM			SetValQueue svq
	INNER JOIN		Restaurant r
	ON				r.RID = svq.RID
	-- grab all records from queue that haven't yet successfully processed
	-- added an index for this, since it is most selective.
	WHERE			svq.SendSuccessDT IS NULL
	-- fail after x attempts so we don't block the queue
	AND				svq.SendAttempts < @MaxSendRetryAttempts
	AND				r.RestStateID <> 16
	AND				r.IsReachable = 1 
	AND				r.RestaurantType in ('E', 'G') -- only allow ERBs and GERBs to get set vals
	-- first in first out queue
	-- this is indexed
	ORDER BY		svq.QueueID
GO

GRANT EXECUTE ON [dbo].[SvcSetValRead] TO ExecuteOnlyRole

GO
