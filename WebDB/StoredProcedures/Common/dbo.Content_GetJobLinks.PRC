if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Content_GetJobLinks]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Content_GetJobLinks]
GO




CREATE PROCEDURE dbo.Content_GetJobLinks
AS
SET NOCOUNT ON
SELECT DeptID as Department_ID,DeptName as Department_Name
FROM DepartmentVW 
WHERE DeptID IN(SELECT DISTINCT JobDeptID FROM JobsOnline WHERE JobActive=1)
ORDER BY DeptName ASC
GO

GRANT EXECUTE ON [Content_GetJobLinks] TO ExecuteOnlyRole

GO
