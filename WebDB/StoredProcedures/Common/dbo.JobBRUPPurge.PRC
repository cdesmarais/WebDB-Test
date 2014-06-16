if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobBRUPPurge]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobBRUPPurge]
GO


CREATE PROCEDURE dbo.JobBRUPPurge
As


--** Retreive the max entry in the queue with out any locking
declare @MinQID int
select	@MinQID = MIN(BRUPQueueID) 
from	BRUPQueue (nolock)
where	CreateDt >= GETDATE() - 7 -- Always keep 7 days

-- Retrieve the most recently Processed item without any locking
-- NOTE: All records are processed sequentially
declare @MaxQID int
select	@MaxQID = MAX(BRUPQueueID) 
from	BRUPQueueProcessed bp (nolock)
where	bp.Processed = 1
and		BRUPQueueID < @MinQID


-- Delete records that have already been processed
delete	BRUPQueue
where	BRUPQueueID <= @MaxQID
-- **  do not delete records that are not completely processed
-- ** Note this is written such that the subselect returns a relatively small set of data
and		BRUPQueueID not in (select	BRUPQueueID
							from	BRUPQueueProcessed 
							where	BRUPQueueID <= @MaxQID 
							and		Processed != 1)


--** Delete the processed queue
delete	BRUPQueueProcessed 
where	BRUPQueueID <= @MaxQID 
and		Processed = 1




GO

GRANT EXECUTE ON JobBRUPPurge TO ExecuteOnlyRole

GO
