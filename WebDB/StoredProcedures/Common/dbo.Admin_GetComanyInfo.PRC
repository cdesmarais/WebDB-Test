if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetCompanyInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetCompanyInfo]
GO

CREATE PROCEDURE dbo.Admin_GetCompanyInfo 
(
	@CompanyID int,
	@CompanyName nvarchar(60)
)

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if (@CompanyID <> 0)
begin
	select CompanyID, CompanyName,Address1, Address2, City, State, Zip,Notes, MetroAreaID,
	CompanyTypeID, CompanyGroupID, Email, Phone, FaxPhone, Logo, AcceptsPoints, OffProperty		   
	from Company where CompanyID = @CompanyID

end
else if (@CompanyName <> null)
begin
	select CompanyID, CompanyName,Address1, Address2, City, State, Zip,Notes, MetroAreaID,
	CompanyTypeID, CompanyGroupID, Email, Phone, FaxPhone, Logo, AcceptsPoints, OffProperty		   
	from Company where CompanyName = @CompanyName
end

GO

GRANT EXECUTE ON [Admin_GetCompanyInfo] TO ExecuteOnlyRole

GO
