if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNi18nAdminCallerAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNi18nAdminCallerAdd]
GO



CREATE PROCEDURE dbo.DNi18nAdminCallerAdd
--NOTE: for now this only saves credit card information for AAUsers (in the CallerCustomer table)...
/*created 10/3/2003*/
(
@Points int,
@PositionID int,
@FirstName nvarchar(255),
@LastName nvarchar(255),
@SortableFirstName nvarchar(255),
@SortableLastName nvarchar(255),
@Email nvarchar(255),
@MetroAreaID int,
@Password  nvarchar(255),
@PasswordQuestionID int,
@PartnerID int,
@PhoneCountryID char(2),
@Phone nvarchar(24),
@SendAnnouncements int,
@BirthMonth int=null,
@BirthYear int=null,
@Salutation int,
@retval  int OUTPUT 
)
As

Declare @CallerID int, @SpecialRequest nvarchar(255)
SET @SpecialRequest = ''

--TODO GG 4/17/2009: Determine who calls DNi18nAdminCallerAdd
-- Defaulting SpecialRequest to an empty string.  Currently SpecialRequest is only set through
-- the web service interface.
  
Exec DNAdminCallerAdd2 @Points, @PositionID, @FirstName, @LastName, @SortableFirstName, @SortableLastName, @Email, @MetroAreaID,
@Password, @PasswordQuestionID, @PartnerID, @PhoneCountryID, @Phone, NULL, NULL, @SendAnnouncements, @BirthMonth, @BirthYear,
@Salutation, @SpecialRequest, @CallerID OUTPUT

Select @retval  = @CallerID 

GO

GRANT EXECUTE ON [DNi18nAdminCallerAdd] TO ExecuteOnlyRole

GO
