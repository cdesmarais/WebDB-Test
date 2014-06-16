if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenOldJobFetch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[TopTenOldJobFetch]
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

/*	
	Procedure to get the stale TopTenImportJobs
*/
CREATE PROCEDURE [dbo].[TopTenOldJobFetch]

AS
SET NOCOUNT ON
SET TRANSACTION isolation LEVEL READ uncommitted

------------------------------------------------------------------------------
-- Keep one inactive job for backup
------------------------------------------------------------------------------
DECLARE @SaveID int

SET @SaveID = (	SELECT TOP 1 TopTenImportJobID 
				FROM		TopTenImportJob ttij
				INNER JOIN	TopTenImportJobStatus ttijs
				ON			ttij.Status = ttijs.TopTenImportJobStatusID
				WHERE		TopTenImportJobStatusName = 'INACTIVE'
				ORDER BY	CreateDate DESC)

------------------------------------------------------------------------------
-- Fetch a list of inactive jobs excluding the most recent
------------------------------------------------------------------------------
SELECT			TopTenImportJobID
FROM			TopTenImportJob ttij
INNER JOIN		TopTenImportJobStatus ttijs
ON				ttij.Status = ttijs.TopTenImportJobStatusID
WHERE			TopTenImportJobID <> @SaveID
AND				TopTenImportJobStatusName in ('INACTIVE','FAIL')
GO

GRANT EXECUTE ON [dbo].[TopTenOldJobFetch] TO ExecuteOnlyRole
GO

