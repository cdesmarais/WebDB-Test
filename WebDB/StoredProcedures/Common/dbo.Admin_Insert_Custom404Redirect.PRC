if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Insert_Custom404Redirect]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Insert_Custom404Redirect]
GO

CREATE PROCEDURE [dbo].[Admin_Insert_Custom404Redirect]  
(   
   @TermValue nvarchar(100)
  ,@TermURL nvarchar(500)
  ,@IsActive bit
)  
AS 

BEGIN TRANSACTION

if Exists(Select * From Custom404 Where Terms = @TermValue) Goto dup_term

	insert into	Custom404 (Terms, RedirectTo, IsActive)
	values	(@TermValue, @TermURL, @IsActive)	

	if (@@ERROR <> 0)
		goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
ROLLBACK TRANSACTION
Return(1)	

dup_term:
ROLLBACK TRANSACTION
RAISERROR('The Term you entered already exists.',17,1)
RETURN(2)
GO
  
grant execute on [dbo].[Admin_Insert_Custom404Redirect] to ExecuteOnlyRole
GO

