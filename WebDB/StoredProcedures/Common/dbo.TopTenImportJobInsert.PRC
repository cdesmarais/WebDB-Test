if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenJobInsert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenJobInsert]
GO
/*	
	Procedure to insert a job id and 
	return the job id in the output param 
*/
CREATE PROCEDURE dbo.TopTenJobInsert

AS
SET NOCOUNT ON

DECLARE @JobStatusId int;

SET @JobStatusId = (SELECT	TopTenImportJobStatusId
					FROM	TopTenImportJobStatus
					WHERE	TopTenImportJobStatusName = 'NEW')
					
------------------------------------------------------------------------------
-- This insert initiates a top ten list job
------------------------------------------------------------------------------

INSERT INTO [dbo].[TopTenImportJob]
           ([CreateDate]
           ,[Status])
     VALUES
           (getDate()
           ,@JobStatusId)
           
------------------------------------------------------------------------------
-- Return the inserted job id
------------------------------------------------------------------------------           
SELECT scope_identity()           

GO


GRANT EXECUTE ON [dbo].[TopTenJobInsert] TO ExecuteOnlyRole

GO

