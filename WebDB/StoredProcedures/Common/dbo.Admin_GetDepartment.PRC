if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetDepartment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetDepartment]
GO




CREATE PROCEDURE dbo.Admin_GetDepartment

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DeptName ,DeptID, DisplayOnJob
FROM DepartmentVW
ORDER BY DeptName
GO

GRANT EXECUTE ON [Admin_GetDepartment] TO ExecuteOnlyRole

GO
