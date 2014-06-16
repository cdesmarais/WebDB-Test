if exists (select * from dbo.sysobjects where ID = object_ID(N'[dbo].[Admin_UpdateEmailTemplate]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdateEmailTemplate]
GO

-- Returns list of specific email template
-- This proc is cloned as Admin_UpdateEmailTemplateForLanguageID, please repeat
-- any changes to this proc to that one.

CREATE PROCEDURE dbo.Admin_UpdateEmailTemplate
(
	@theEmailTemplateID int,
	@theTemplateDetailsID int,
	@inputDesc nvarchar(200),
	@inputFromDisplay nvarchar(100),
	@inputSubject nvarchar(200),
	@inputBody ntext,
	@inputIncHeader bit,
	@inputIncFooter bit,
	@inputUpdatedBy nvarchar(100),
	@inputActive bit,
	@inputDefaultTemplate bit
) 
As
SET NOCOUNT ON

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @id int

set @ProcName = 'Admin_UpdateEmailTemplate'
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
--** call the "with language" proc and let it do the work
--** mmc 1/4/81
--**********************
EXEC dbo.Admin_UpdateEmailTemplateForLanguageID @theEmailTemplateID = @theEmailTemplateID,
												@theTemplateDetailsID = @theTemplateDetailsID,
												@inputDesc = @inputDesc,
												@inputFromDisplay = @inputFromDisplay,
												@inputSubject = @inputSubject,
												@inputBody =@inputBody,
												@inputIncHeader = @inputIncHeader,
												@inputIncFooter = @inputIncFooter,
												@inputUpdatedBy = @inputUpdatedBy,
												@inputActive = @inputActive,
												@inputDefaultTemplate = @inputDefaultTemplate,
												@LanguageID = @LanguageID
-- Done
Return(0)

general_error:
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)
GO

GRANT EXECUTE ON [Admin_UpdateEmailTemplate] TO ExecuteOnlyRole

GO
