if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenJobFail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[TopTenJobFail]
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

/*	
	Procedure to set a job status to failure
*/
CREATE PROCEDURE [dbo].[TopTenJobFail]
(
	@JobID		int
)

AS

SET NOCOUNT ON
------------------------------------------------------------------------------
-- Job Status Fail
------------------------------------------------------------------------------
declare @Fail int, @Active int
SET @Fail =	4
SET @Active = 1

------------------------------------------------------------------------------
-- Transaction setup
------------------------------------------------------------------------------
SET TRAN ISOLATION LEVEL SERIALIZABLE

DECLARE @err int, @rowcount int

BEGIN TRANSACTION TTJobFail
		
------------------------------------------------------------------------------
-- Set designated job to fail
------------------------------------------------------------------------------		
UPDATE TopTenImportJob
SET Status = @Fail
Where TopTenImportJobID = @JobID
AND Status <> @Active

Select @err = @@ERROR, @rowcount = @@ROWCOUNT

IF (@err <> 0) 
		GOTO general_error
		
IF (@rowcount <> 1)
		GOTO rowcount_error

COMMIT TRANSACTION TTJobFail
RETURN(0)


-- Handle Error cases.

general_error:
	ROLLBACK TRANSACTION TTJobFail
	RAISERROR('1',16,2) -- Generic error message	
	RETURN(1)

rowcount_error:
	ROLLBACK TRANSACTION TTJobFail
	RAISERROR('Rowcount is not 1',16,2) -- Rowcount Error Msg
	RETURN(1)
GO

GRANT EXECUTE ON [dbo].[TopTenJobFail] TO ExecuteOnlyRole
GO

