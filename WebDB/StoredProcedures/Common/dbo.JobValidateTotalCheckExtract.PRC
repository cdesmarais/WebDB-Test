if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobValidateTotalCheckExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobValidateTotalCheckExtract]
GO

CREATE Procedure dbo.JobValidateTotalCheckExtract
as
--******************************************************************************
--Procedure select data from giftRedemption and update the value lookup table
--This will be a working giftredmptionID that is used to track export for dinning check redemption
--******************************************************************************

SET NOCOUNT ON

SET TRAN ISOLATION LEVEL READ UNCOMMITTED

declare @ErrorMsg as nvarchar(1000)
declare @StartBatchCount as int
declare @EndBatchCount as int

set @ErrorMsg = 'Total dinning check export count is not correct'

select @StartBatchCount=ValueInt from  valuelookup
where LKey = 'DiningCHKBatchStartCount' 

select @EndBatchCount=ValueInt from  valuelookup
where LKey = 'DiningCHKBatchFinalCount'

--Update the expected total number for batch out
IF (@StartBatchCount<>@EndBatchCount) goto error
	--If all is well...
	Return(0)

error:
	exec DNErrorAdd 88, 'JobValidateTotalCheckExtract', 'Unable to select Check Extract', 1
	raisError ('throw error',15, 1)
GO

GRANT EXECUTE ON [JobValidateTotalCheckExtract] TO ExecuteOnlyRole

GO





