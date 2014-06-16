if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Update_Custom404Redirect]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Update_Custom404Redirect]
GO

CREATE PROCEDURE [dbo].[Admin_Update_Custom404Redirect]  
(  
  @TermID int
  ,@TermValue nvarchar(100)
  ,@TermURL nvarchar(500)
  ,@IsActive bit
)  
AS 

BEGIN TRANSACTION

if Exists(Select * From Custom404 Where Terms = @TermValue and Custom404ID <> @TermID) Goto dup_term

	Update	Custom404
	Set 	Terms = @TermValue
			,RedirectTo = @TermURL
			,IsActive = @IsActive	
	where	Custom404ID = @TermID  

	if (@@ERROR <> 0)
		goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
ROLLBACK TRANSACTION
Return(0)

dup_term:
ROLLBACK TRANSACTION
RAISERROR('The Term you entered already exists.',17,1)
RETURN(2)
GO

grant execute on [Admin_Update_Custom404Redirect] to ExecuteOnlyRole
GO



