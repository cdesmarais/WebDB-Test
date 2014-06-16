if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessWFB_HExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessWFB_HExtract]
GO

CREATE Procedure dbo.JobProcessWFB_HExtract
as
--******************************************************************************
--Procedure export US only Header Records flat file
--******************************************************************************

SET NOCOUNT ON

Declare @FileControlNumber int
		,@FileDate datetime
		,@TransactionID int

declare @ErrorMsg as nvarchar(1000)

set @ErrorMsg = 'Failed to select Header Records'

if (select count(*) from DCHK_HRecord where export = 0) <>1 --must only have 1 filecontrol number
	goto error

select @FileControlNumber=FileControlNumber 
from DCHK_HRecord where export = 0 

SELECT	[RecordID]
		,[FileControlNumber]
		,CONVERT(CHAR(10), FileDate, 23) FileDate
		,[EndOfRecord]
		FROM [DCHK_HRecord]
		where FileControlNumber = @FileControlNumber
		
if @@ERROR <> 0
	goto error


--If all is well...
Return(0)

error:
	exec DNErrorAdd 888, 'JobProcessWFB_HExtract', @ErrorMsg, 1	
	raisError ('throw error',15, 1)

GO

GRANT EXECUTE ON [JobProcessWFB_HExtract] TO ExecuteOnlyRole

GO





