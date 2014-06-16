if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetCompanyInfoByName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetCompanyInfoByName]
GO

CREATE PROCEDURE dbo.Admin_GetCompanyInfoByName @CompanyName nvarchar(60)

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	select * from Company where CompanyName = @CompanyName

GO

GRANT EXECUTE ON [Admin_GetCompanyInfoByName] TO ExecuteOnlyRole

GO
