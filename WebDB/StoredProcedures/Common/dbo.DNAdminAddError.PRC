if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAdminAddError]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAdminAddError]
GO


CREATE PROCEDURE dbo.DNAdminAddError
  @msgtext nvarchar(255),
  @notes nvarchar(255),
  @LID int,
  @ErrCode nvarchar(50),
  @errortype int,
  @ErrID int = 0
AS
DECLARE @ErrorID int
SELECT @ErrorID = @ErrID

SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION MyTran


	declare @ProcName as nvarchar(1000)
	declare @Action as nvarchar(3000)
	declare @DBError int

	set @ProcName = 'DNAdminAddError'

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
	--** Insert into Error Table
	--**********************
	set @Action = 'Insert Into Error'
    Insert Into Error(notes,ErrorTypeID)
    Values(@notes,@errortype)
    set @DBError = @@error
	if @DBError <> 0
		goto general_error

	set @ErrorID=scope_identity()

	--**********************
	--** Insert into ErrorMessage
	--**********************
	set @Action = 'Insert Into ErrorMessage'
    Insert Into ErrorMessage(Error.ErrorID,ErrorMessage,ErrorCode, LanguageID)
    Values(@ErrorID,@msgtext,@ErrCode, @LanguageID)
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



GRANT EXECUTE ON [DNAdminAddError] TO ExecuteOnlyRole

GO
