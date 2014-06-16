if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessWFB_TExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessWFB_TExtract]
GO

CREATE Procedure dbo.JobProcessWFB_TExtract
as
--******************************************************************************
--Procedure export US only Trailer Records flat file
--******************************************************************************

SET NOCOUNT ON

Declare @FileControlNumber int
		,@FileDate datetime
		,@TransactionID int

declare @ErrorMsg as nvarchar(1000)

set @ErrorMsg = 'Failed to select WFB Trailer Records'

if (select count(*) from DCHK_HRecord where export = 0) <>1 --must only have 1 filecontrol number
	goto error

select @FileControlNumber=FileControlNumber 
from DCHK_HRecord where export = 0 

SELECT 
		[RecordID]
      ,[PaymentCount]
      ,[PaymentAmount]
      ,[EndOfRecord]
	FROM [DCHK_TRecord]
	where FileControlNumber =@FileControlNumber
		
if @@ERROR <> 0
	goto error

--If all is well...
Return(0)

error:
	exec DNErrorAdd 888, 'JobProcessWFB_TExtract', @ErrorMsg, 1	
	raisError ('throw error',15, 1)

GO

GRANT EXECUTE ON [JobProcessWFB_TExtract] TO ExecuteOnlyRole

GO





