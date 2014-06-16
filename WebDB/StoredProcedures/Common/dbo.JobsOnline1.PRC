if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobsOnline1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobsOnline1]
GO




CREATE PROCEDURE dbo.JobsOnline1
 AS
 SET NOCOUNT ON
SELECT *
FROM JobsOnline INNER JOIN Department ON JobsOnline.JobDeptID=Department.DeptID
WHERE JobActive=1
ORDER BY JobActive,DeptName ASC
GO

GRANT EXECUTE ON [JobsOnline1] TO ExecuteOnlyRole

GO
