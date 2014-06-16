if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAdminUpdateError]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAdminUpdateError]
GO


CREATE PROCEDURE dbo.DNAdminUpdateError
  @msgtext nvarchar(255),
  @notes nvarchar(255),
  @LID int,
  @OLID int,
  @errortype int,
  @ErrCode nvarchar(255),
  @MID int
AS

SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION MyTran

	declare @ProcName as nvarchar(1000)
	declare @Action as nvarchar(3000)
	declare @DBError int

	set @ProcName = 'DNAdminUpdateError'

	--**********************
	--** Get Language
	--**********************
	set @Action = 'Retrieve LanguageID'
	declare @LanguageID int
	exec @LanguageID = procGetDBUserLanguageID
	set @DBError = @@error
	if @DBError <> 0
		goto general_error

	--**********************
	--** Update Error
	--**********************
	set @Action = 'Update Error'

    Update	Error
    Set		notes=@notes,
			ErrorTypeID=@errortype
    Where	ErrorID = @MID
	set @DBError = @@error
	if @DBError <> 0
		goto general_error

	--**********************
	--** Update ErrorMessage
	--**********************
	set @Action = 'Update ErrorMessage'

    Update	ErrorMessage
    Set		ErrorMessage=@msgtext, 
			ErrorCode = @ErrCode
    Where	ErrorID = @MID
    and		LanguageID = @LanguageID

	set @DBError = @@error
	if @DBError <> 0
		goto general_error

COMMIT TRAN
RETURN(0)

general_error:
	ROLLBACK TRANSACTION MyTran
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	RAISERROR('general error',17,1)
	RETURN(2)
GO


GRANT EXECUTE ON [DNAdminUpdateError] TO ExecuteOnlyRole

GO
