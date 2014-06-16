if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenJobUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[TopTenJobUpdate]
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

/*	
	Procedure to swap job statuses upon a successful import of list feeds
*/
CREATE PROCEDURE [dbo].[TopTenJobUpdate]
(
	@JobID		int
)

AS

SET NOCOUNT ON
------------------------------------------------------------------------------
-- Job Statuses
------------------------------------------------------------------------------
declare @Active int, @Inactive int, @New int
SET @Active =		1
SET @Inactive =		2
SET @New =			3

------------------------------------------------------------------------------
-- Transaction setup
------------------------------------------------------------------------------
SET TRAN ISOLATION LEVEL SERIALIZABLE

DECLARE @err int, @rowcount int

BEGIN TRANSACTION TTJobUpdate

------------------------------------------------------------------------------
-- Set active jobs to inactive
------------------------------------------------------------------------------
UPDATE TopTenImportJob
SET Status = @Inactive
Where Status = @Active

IF (@@ERROR <> 0) 
		GOTO general_error
		
------------------------------------------------------------------------------
-- Set designated job to active
------------------------------------------------------------------------------		
UPDATE TopTenImportJob
SET Status = @Active
Where TopTenImportJobID = @JobID

Select @err = @@ERROR, @rowcount = @@ROWCOUNT

IF (@err <> 0) 
		GOTO general_error
		
IF (@rowcount <> 1)
		GOTO rowcount_error

COMMIT TRANSACTION TTJobUpdate
RETURN(0)


-- Handle Error cases.

general_error:
	ROLLBACK TRANSACTION TTJobUpdate
	RAISERROR('1',16,2) -- Generic error message	
	RETURN(1)

rowcount_error:
	ROLLBACK TRANSACTION TTJobUpdate
	RAISERROR('Rowcount is not 1',16,2) -- Rowcount Error Msg
	RETURN(1)
GO

GRANT EXECUTE ON [dbo].[TopTenJobUpdate] TO ExecuteOnlyRole
GO

