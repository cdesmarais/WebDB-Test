if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNi18nCallerUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNi18nCallerUpdate]
GO

CREATE PROCEDURE dbo.DNi18nCallerUpdate

@CallerID int,
@FirstName nvarchar(255),
@LastName nvarchar(255),
@SortableFName nvarchar(255),
@SortableLName nvarchar(255),
@Email nvarchar(255),
@Login nvarchar(255),
@Address1 nvarchar(128),
@Address2 nvarchar(128),
@City nvarchar(40),
@State nvarchar(40),
@ZipCode nvarchar(20),
@Country char(2),
@MetroAreaID int,
@Password  nvarchar(255),
@PhoneCountryID char(2),
@Phone nvarchar(24),
@SendAnnouncements bit,
@BirthMonth int=null,
@BirthYear int=null,
@Salutation int,
@Notes nvarchar(255)=null,
@PwdQuestionID int,
@PwdAnswer nvarchar(255),
@retval int  = 0 OUTPUT 
As

Declare @UpdateStatus int
Set @UpdateStatus = 0

Exec DNCallerUpdate @CallerID, @FirstName, @LastName, @SortableFName, @SortableLName, @Email, @Login, 
@Address1, @Address2, @City, @State, @ZipCode, @Country, @MetroAreaID, @Password, @PhoneCountryID,
@Phone,NULL, NULL, @SendAnnouncements, @BirthMonth, @BirthYear, @Salutation, @Notes, @PwdQuestionID,
@PwdAnswer, @UpdateStatus OUTPUT


Select @retVal = @UpdateStatus



GO


GRANT EXECUTE ON [DNi18nCallerUpdate] TO ExecuteOnlyRole

GO
