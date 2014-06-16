if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNBRUPRead]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNBRUPRead]
GO


CREATE PROCEDURE dbo.DNBRUPRead
(
	 @RIDMod	int,
	 @RIDModFilter int
)
As
--*******************************************
--** Retrieves all binary reso update batches
--*******************************************

set nocount on

--** Retreive the max entry in the queue with out any locking
declare @MaxQID int
select	@MaxQID = MAX(BRUPQueueID) 
from	BRUPQueue (nolock)

-- Retrieve the most recently Processed item without any locking
-- NOTE: All records are processed sequentially
declare @MinQID int
select	@MinQID = MAX(BRUPQueueID) 
from	BRUPQueueProcessed bp (nolock)
where	bp.Processed = 1

declare @WebUmami_IsEnabled int
select @WebUmami_IsEnabled = coalesce(ValueInt, 0) from ValueLookup where LKey = 'WebUmami_IsEnabled' 

-- As a precaution set the minQID back 10000 records 
-- this is just incase there are multiple BRUP processors 
set @MinQID = IsNull(@MinQID, @MaxQID) - 10000


	SELECT		b.BRUPQueueID
				,b.BRUPMessage
				,ISNULL(bp.LastSequenceIdProcessed,-1) LastSequenceIdProcessed
				,ISNULL(b.IsUmamiJSON, convert(bit, 0)) IsUmamiJSON
	FROM		BRUPQueue b (nolock)
	LEFT JOIN	BRUPQueueProcessed bp (nolock)
	ON			b.BRUPQueueID = bp.BRUPQueueID

	where		b.BRUPQueueID between @MinQID and @MaxQID
	and			IsNull(Processed,0) != 1 -- Do not include processed messages
	and			(@WebUmami_IsEnabled = 1 OR coalesce(b.IsUmamiJSON, 0) = 0) -- suppress UmamiJSON from reader results if feature switch is off
	-- Filter out RIDs based on Mod filter so that multiple OTServices can operate concurrently
	-- (RID / 3) this is done to account for the regional identities of restaurants
	and			((RID / 3) % @RIDMod) = @RIDModFilter 
	ORDER BY	b.BRUPQueueID asc

GO

GRANT EXECUTE ON DNBRUPRead TO ExecuteOnlyRole

GO
