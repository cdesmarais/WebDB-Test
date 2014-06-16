if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_JobsGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_JobsGet]
GO

CREATE PROCEDURE dbo.Admin_JobsGet
    @department nvarchar(4),
    @active nvarchar(4)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF @department = '0' SELECT @department = ''
IF @active = '2' SELECT @active = ''

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
FROM		JobsOnlineVW 
INNER JOIN	Department 
ON		JobDeptID=DeptID 
Where		(LEN(@department) = 0 OR CHARINDEX(',' + CAST(JobDeptID AS nvarchar(4))+ ',',',' + @department + ',') > 0) 
And			(LEN(@active) = 0 OR CHARINDEX(',' + CAST(JobActive AS nvarchar(4)) + ',',',' + @active + ',') > 0) 
ORDER BY	JobActive desc
			,DeptName ASC



GO

GRANT EXECUTE ON [Admin_JobsGet] TO ExecuteOnlyRole

GO
