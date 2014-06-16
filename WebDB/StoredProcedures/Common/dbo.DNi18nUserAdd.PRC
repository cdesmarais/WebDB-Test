if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNi18nUserAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNi18nUserAdd]
GO




CREATE Procedure dbo.DNi18nUserAdd
  (
	@Salutation int,
	@FirstName nvarchar(255),
	@LastName nvarchar(255),
	@SortableFirstName nvarchar(255),
	@SortableLastName nvarchar(255),
	@Email nvarchar(255),
	@Password nvarchar(255),
	@PhoneCountryID char(2),
	@DayPhone nvarchar(24),
	@DefaultGeoID int,
	@ConsumerType int=null,
	@SendPromos bit,
	@Points int=300,
	@PartnerID int,
	@DiningFormFeedbackSetting bit,
	@retval int OUTPUT
  )
/* New for DotNet. 10/1/2003 KS */
 
As

DECLARE @UserID int, @SpecialRequest nvarchar(999)
	SET @retval =  0
	SET @SpecialRequest = ''

--TODO GG 4/17/2009: Determine who calls DNi18nUserAdd
-- Defaulting SpecialRequest to an empty string.  Currently SpecialRequest is only set through
-- the web service interface.

Exec DNUserAdd2 @Salutation, @FirstName, @LastName, @SortableFirstName, @SortableLastName, @Email, @Password, @PhoneCountryID, @DayPhone, NULL, NULL, @DefaultGeoID, @ConsumerType, @SendPromos, @Points, @PartnerID, @DiningFormFeedbackSetting, @SpecialRequest, @UserID OUTPUT

-- Set the return value and exit.
SELECT @retval= @UserID

GO

GRANT EXECUTE ON [DNi18nUserAdd] TO ExecuteOnlyRole

GO
