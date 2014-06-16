if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Admin_CompanyType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Admin_CompanyType]
GO



CREATE PROCEDURE dbo.Concierge_Admin_CompanyType
As
SET NOCOUNT ON

BEGIN TRANSACTION
SELECT CompanyTypeID AS CompanyTypeID,CompanyTypeDesc AS CompanyTypeName
FROM CompanyType
ORDER BY CompanyTypeDesc
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Admin_CompanyType] TO ExecuteOnlyRole

GO
