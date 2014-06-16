

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Concierge_Caller_Create1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Concierge_Caller_Create1]
go

  
create procedure dbo.Admin_Concierge_Caller_Create1  
 (  
  @FirstName nvarchar(255),  
  @LastName nvarchar(255),  
  @SFirstName nvarchar(255),  
  @SLastName nvarchar(255),  
  @login nvarchar(255),  
  @Email nvarchar(255) = null,  
  @Country nvarchar(2) = null,  
  @Phone nvarchar(24),  
  @DefaultGeoID int,  
  @HotelID int,  
  @PartnerID int,  
  @CompanyMetroID int,
  @retval int OUTPUT
 )  
as  
set NOCOUNT on  
DECLARE @UserID int,@n int  
set DATEFORMAT mdy  
set TRAN ISOLATION LEVEL SERIALIZABLE  
BEGIN TRAN  
  
-- Check that the email address is not already in use.  
if exists(select LoginName from caller where LoginName=@login) goto dup_email  
  
-- Check that the email address is not already in use.if exists(select LoginName from Caller where LoginName=@login) goto dup_email  
if @Email is null and exists(Select Email from Company where CompanyID = @HotelID)  
BEGIN  
select @Email = Email from Company where CompanyID = @HotelID  
END  
  
-- if country is null, set it to the country of the company  
if (@Country is null)  
BEGIN  
select @Country = Country from Company where CompanyID = @HotelID  
END  
  
--Create the Caller row.  
insert into Caller  
 (FName,LName,SFName,SLName,EMail,metroareaid,CompanyID,PositionID,LoginName,PwdQuestionID,PartnerID,Points,CompanyMetroID)  
values (@FirstName,@LastName,@SFirstName,@SLastName,@Email,@DefaultGeoID,@HotelID,2,@login,99,@PartnerID,0,@CompanyMetroID)  
  
if (@@ERROR <> 0)  
 goto dup_email  
  
select @UserID = scope_identity()  
  
insert into CallerPhone  
 (PhoneTypeID,CallerID,Phone, PhoneCountryID, IsPrimary)  
values (6,@UserID,@Phone, @Country, 1)  
  
if @@Error <> 0  
 goto general_error  
  
COMMIT TRAN  
select @retval = @UserID  
RETURN(0)  
  
dup_email:  
ROLLBACK TRAN  
RAISERROR('116' ,16,2) --'That email address is already in use.'  
RETURN(1)  
  
general_error:  
ROLLBACK TRAN  
RAISERROR('6' ,16,2) --'Error adding new Customer.'  
RETURN(2)  
  
go

GRANT EXECUTE ON [Admin_Concierge_Caller_Create1] TO ExecuteOnlyRole

go  