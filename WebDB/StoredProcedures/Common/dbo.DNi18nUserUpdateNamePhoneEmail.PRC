if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNi18nUserUpdateNamePhoneEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNi18nUserUpdateNamePhoneEmail]
GO

CREATE PROCEDURE dbo.DNi18nUserUpdateNamePhoneEmail
(
@CustID int
,@FName nvarchar(60) 
,@LName nvarchar(60) 
,@SortableFName nvarchar(60) 
,@SortableLName nvarchar(60) 
,@PhoneCountryID char(2)
,@Phone nvarchar(24)
,@Email nvarchar(255) 
)
 AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @FName = '' 	
	set @FName = null
if @LName = ''
	set @LName = null
if @PhoneCountryID = ''
	set @PhoneCountryID = null
if @Phone = ''
	set @Phone = null
if @Email = ''
	set @Email = null


update Customer
set 
FName = coalesce(@FName,FName)
,LName = coalesce(@LName,LName)
,SFName = coalesce(@SortableFName,SFName)
,SLName = coalesce(@SortableLName,SLName)
,Email = coalesce (@Email,Email)
where CustID = @CustID

update CustomerPhone
set
PhoneCountryID = coalesce(@PhoneCountryID, PhoneCountryID),
Phone = coalesce(@Phone,Phone)
where CustID = @CustID
and PhoneTypeID = 1 --Home

GO

GRANT EXECUTE ON [DNi18nUserUpdateNamePhoneEmail] TO ExecuteOnlyRole

GO
