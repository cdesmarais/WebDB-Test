if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateUserLastResoPhoneType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateUserLastResoPhoneType]
GO

CREATE Procedure dbo.DNUpdateUserLastResoPhoneType
  (
	@UserID int,
	@LastResoPhoneTypeID int,
	@IsCaller bit	
  )
As
SET NOCOUNT ON

SET TRAN ISOLATION LEVEL READ UNCOMMITTED

  
if(@IsCaller = 0)
Begin
	Update Customer set LastResoPhoneTypeID = @LastResoPhoneTypeID where CustID = @UserID
	if (@@error <> 0) GOTO general_error
End
Else
Begin
	Update Caller set LastResoPhoneTypeID = @LastResoPhoneTypeID where CallerID = @UserID
	if (@@error <> 0) GOTO general_error
End

RETURN(0)

-- Handle Error cases.
general_error:
	RAISERROR('6',16,2) --Error updating LastResoPhoneType.
	RETURN(5)
Go

GRANT EXECUTE ON [DNUpdateUserLastResoPhoneType] TO ExecuteOnlyRole

GO
