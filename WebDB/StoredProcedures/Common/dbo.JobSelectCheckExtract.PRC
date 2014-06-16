if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobSelectCheckExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobSelectCheckExtract]
GO

CREATE Procedure dbo.JobSelectCheckExtract
as
--******************************************************************************
--Procedure select data from giftRedemption and update the value lookup table
--This will be a working giftredmptionID that is used to track export for dinning check redemption
--******************************************************************************

SET NOCOUNT ON

SET TRAN ISOLATION LEVEL READ UNCOMMITTED

declare @ErrorMsg as nvarchar(1000)
declare @MaxGiftRedemptionID as int

set @ErrorMsg = 'Failed to update lookup table checkRedemptionID'

Begin Transaction

select @maxGiftRedemptionID = max(giftRedemptionID) from giftRedemption 
		where extracted =0

if @@ERROR <> 0 goto error

	update  valuelookup
		set ValueInt = @maxGiftRedemptionID,
			valueDT = getdate()
	where LType = 'DATABASE' and
		  LKey = 'DiningCheckExtract'

if @@ERROR <> 0 goto error
--Reset the Batch Count Final
	update  valuelookup
		set ValueInt = 0,
			valueDT = getdate()
	where LType = 'DATABASE' and
		  LKey = 'DiningCHKBatchFinalCount'

if @@ERROR <> 0 goto error

--Update the expected total number for batch out
	update  valuelookup
		set ValueInt = (select count(*) from giftRedemption 
						where GiftRedemptionID <= @maxGiftRedemptionID 
						and extracted = 0),
			valueDT = getdate()
	where LType = 'DATABASE' and
		  LKey = 'DiningCHKBatchStartCount'

if @@ERROR <> 0 goto error
Commit Transaction
	--If all is well...
	Return(0)

error:
	ROLLBACK
	exec DNErrorAdd 88, 'JobSelectCheckExtract', 'Unable to select Check Extract', 1
	raisError ('throw error',15, 1)
GO

GRANT EXECUTE ON [JobSelectCheckExtract] TO ExecuteOnlyRole

GO





