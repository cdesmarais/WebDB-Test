if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_GetCompanyInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserSvc_GetCompanyInfo]
GO


CREATE PROCEDURE dbo.UserSvc_GetCompanyInfo
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	select	CompanyID,
			Email,
			Country,
			Phone,
			Logo,
			IsNull(AcceptsPoints, 1) as AcceptsPoints, 
			CompanyName,
			Address1,
			Address2,
			City,
			State,
			Zip
	from company

GO


GRANT EXECUTE ON [UserSvc_GetCompanyInfo] TO ExecuteOnlyRole

GO
