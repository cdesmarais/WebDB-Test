if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Admin_Company_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Admin_Company_Update]
GO



CREATE PROCEDURE dbo.Concierge_Admin_Company_Update
 (
  @CompanyName nvarchar(255),
  @Company_ID int,
  @CompanyEmail nvarchar(255),
  @Address1 nvarchar(255),
  @Address2 nvarchar(255),
  @City nvarchar(255),
  @StateID nvarchar(255),
  @CountryID char(2) = 'US',
  @PostalCode nvarchar(255),
  @HoodCity int,
  @CompanyType int,
  @CompanyGroup int,
  @Notes nvarchar(999),
  @Phone nvarchar(24),
  @FaxPhone nvarchar(24),
  @logo nvarchar(999),
  @AcceptsPoints int,
  @OffProperty int  
 )
As
SET NOCOUNT ON

BEGIN TRANSACTION
UPDATE Company
SET CompanyName = @CompanyName,
	EMail = @CompanyEmail,
	Address1 = @Address1,
	Address2=@Address2,
	City = @City,
	State = @StateID,
	Zip = @PostalCode,
	Notes = @Notes,
	metroareaid = @HoodCity,
	CompanyTypeID = @CompanyType,
	CompanyGroupID = @CompanyGroup,
	Phone = @Phone,
	FaxPhone = @FaxPhone,
	Logo = @Logo,
	acceptspoints = @AcceptsPoints,
	offProperty = @OffProperty,	
	Country = @CountryID
WHERE CompanyID =  @Company_ID
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO


GRANT EXECUTE ON [Concierge_Admin_Company_Update] TO ExecuteOnlyRole

GO
