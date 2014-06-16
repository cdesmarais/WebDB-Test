if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Admin_CompanyGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Admin_CompanyGroup]
GO



CREATE PROCEDURE dbo.Concierge_Admin_CompanyGroup
As
SET NOCOUNT ON

BEGIN TRANSACTION
SELECT CompanyGroupID AS CompanyGroupID,CGName AS CompanyGroupName
FROM CompanyGroup
ORDER BY CGName
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Admin_CompanyGroup] TO ExecuteOnlyRole

GO
