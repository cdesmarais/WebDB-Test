if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_JobUpdateGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_JobUpdateGet]
GO

CREATE PROCEDURE dbo.Admin_JobUpdateGet

(@Job_ID int
 )

As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 
			 JobID
			,JobDeptID
			,JobPositionTitle
			,JobPositionLocation
			,JobPositionDescription
			,JobResponsibilities
			,JobRequirements
			,JobActive
			,JobContactName
			,JobContactMail
			,DeptName
			,JobDesired 
			,JobAppUrl
FROM		JobsOnlineVW 
INNER JOIN	Department 
ON		JobDeptID=DeptID 
WHERE		 JobID = @Job_ID

GO

GRANT EXECUTE ON [Admin_JobUpdateGet] TO ExecuteOnlyRole

GO

