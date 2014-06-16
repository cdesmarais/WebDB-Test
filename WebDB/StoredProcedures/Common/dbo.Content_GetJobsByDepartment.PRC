if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Content_GetJobsByDepartment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Content_GetJobsByDepartment]
GO




CREATE PROCEDURE dbo.Content_GetJobsByDepartment
AS
SET NOCOUNT ON
SELECT JobID as Job_ID,JobsOnline.JobDeptID as Job_Department_ID,JobPositionTitle as Job_position_title,
JobPositionLocation as Job_position_location,JobPositionDescription as Job_position_description,JobResponsibilities as Job_responsibilities,
JobRequirements as Job_requirements,JobContactName as Job_Contact_Name,JobContactMail as Job_Contact_Mail,
JobDesired as Job_desired,Department.DeptName as Department_Name,
JobAppUrl as JobAppUrl
FROM JobsOnlineVW as JobsOnline 
INNER JOIN Department ON JobsOnline.JobDeptID=Department.DeptID
WHERE JobActive=1
ORDER BY JobActive,DeptName ASC
GO

GRANT EXECUTE ON [Content_GetJobsByDepartment] TO ExecuteOnlyRole

GO
