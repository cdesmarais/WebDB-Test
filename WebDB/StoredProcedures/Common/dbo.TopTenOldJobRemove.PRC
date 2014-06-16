if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenJobRemove]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[TopTenJobRemove]
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

/*	
	Procedure to remove old TopTenImportJobs
*/
CREATE PROCEDURE [dbo].[TopTenJobRemove]
(
	@JobID int
)
	
AS

SET NOCOUNT ON

------------------------------------------------------------------------------
-- Transaction setup
------------------------------------------------------------------------------
SET TRAN ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION TTJobRemove

------------------------------------------------------------------------------
-- Remove the restaurants first, they're at the bottom of the
-- FK chain
------------------------------------------------------------------------------
DELETE TopTenListRestaurant
FROM TopTenListInstance ttli
INNER JOIN TopTenListRestaurant ttlr
ON ttlr.TopTenListInstanceID = ttli.TopTenListInstanceID
INNER JOIN TopTenImportJob ttij
ON ttli.TopTenImportJobID = ttij.TopTenImportJobID
INNER JOIN TopTenImportJobStatus ttijs
ON ttijs.TopTenImportJobStatusID = ttij.Status
WHERE ttijs.TopTenImportJobStatusName in ('INACTIVE','FAIL')
AND ttij.TopTenImportJobID = @JobID

IF (@@ERROR <> 0) 
		GOTO general_error
------------------------------------------------------------------------------
-- Remove the list instances next.
------------------------------------------------------------------------------
DELETE TopTenListInstance
FROM TopTenImportJob ttij
INNER JOIN TopTenListInstance ttli
ON ttli.TopTenImportJobID = ttij.TopTenImportJobID
inner join TopTenImportJobStatus ttijs
ON ttij.Status = ttijs.TopTenImportJobStatusID
WHERE ttijs.TopTenImportJobStatusName in ('INACTIVE','FAIL')
AND ttij.TopTenImportJobID = @JobID

IF (@@ERROR <> 0) 
		GOTO general_error
------------------------------------------------------------------------------
-- Finally, remove the job from the import table
------------------------------------------------------------------------------
DELETE TopTenImportJob
FROM TopTenImportJobStatus ttijs
inner join TopTenImportJob ttij
ON ttij.Status = ttijs.TopTenImportJobStatusID
WHERE ttijs.TopTenImportJobStatusName in ('INACTIVE','FAIL')
AND ttij.TopTenImportJobID = @JobID

IF (@@ERROR <> 0) 
		GOTO general_error

COMMIT TRANSACTION TTJobRemove
RETURN(0)


-- Handle Error cases.

general_error:
	ROLLBACK TRANSACTION TTJobRemove
	RAISERROR('1',16,2) -- Generic error message
	RETURN(1)
	
GO	

GRANT EXECUTE ON [dbo].[TopTenJobRemove] TO ExecuteOnlyRole

GO

