
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessMostBookedEUAsiaUpdateStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessMostBookedEUAsiaUpdateStatus]
GO

CREATE PROCEDURE dbo.JobProcessMostBookedEUAsiaUpdateStatus

AS
SET NOCOUNT ON
set transaction isolation level read uncommitted


BEGIN TRANSACTION

DECLARE @TopTenImportJobID AS INT

SELECT @TopTenImportJobID = MAX(TopTenImportJobID) FROM [TopTenImportJob]

--------------------------------------------------------------------------
-- begin Update status of jobs and Lists
--------------------------------------------------------------------------

UPDATE	[TopTenImportJob] 
SET		[Status] = 2 
WHERE	TopTenImportJobID 
IN		(
		SELECT TopTenImportJobID 
		FROM [TopTenImportJob] 
		WHERE status = 1
		)

UPDATE	[TopTenImportJob] 
SET		[Status] = 1 
WHERE	TopTenImportJobID = @TopTenImportJobID

UPDATE	[TopTenListInstance] 
SET		[IsActive] = 0 
WHERE	TopTenImportJobID != @TopTenImportJobID

UPDATE	[TopTenListInstance] 
SET		[IsActive] = 1 
WHERE	TopTenImportJobID = @TopTenImportJobID

--------------------------------------------------------------------------
-- end Update status of jobs and Lists
--------------------------------------------------------------------------


if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)



GO


GRANT EXECUTE ON [JobProcessMostBookedEUAsiaUpdateStatus] TO ExecuteOnlyRole

GO



