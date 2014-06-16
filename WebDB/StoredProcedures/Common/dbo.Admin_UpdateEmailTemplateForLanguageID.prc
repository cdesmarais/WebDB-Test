if exists (select * from dbo.sysobjects where ID = object_ID(N'[dbo].[Admin_UpdateEmailTemplateForLanguageID]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
drop procedure [dbo].Admin_UpdateEmailTemplateForLanguageID
GO

-- Returns list of specific email template
CREATE PROCEDURE dbo.Admin_UpdateEmailTemplateForLanguageID
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
	@inputDefaultTemplate bit,
	@LanguageID int -- new MMC
) 
As
SET NOCOUNT ON

BEGIN TRANSACTION
declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @id int

set @ProcName = 'Admin_UpdateEmailTemplateForLanguageID'

--**********************
--** insert into EmailTemplateDetailsChangeLog
--**********************
set @Action = 'insert into EmailTemplateDetailsChangeLog'

-- read existing data..
-- copy the existing email template into the version table..
insert into EmailTemplateDetailsChangeLog(
			EmailTemplateID, 
			EmailFromDisplay, 
			Subject, 
			EmailBody, 
			UpdatedBy, 
			UpdateDateTS, 
			Active, 
			DefaultTemplate, 
			IncludeHeader, 
			IncludeFooter,
			LanguageID
	)
	select	EmailTemplateID, 
			EmailFromDisplay,
			subject,
			emailbody,
			updatedby,
			updatedatets,
			active,
			defaulttemplate,
			includeheader,
			includefooter,
			LanguageID 
	from	EmailTemplateDetails 
	where	EmailTemplateID= @theEmailTemplateID
	and		LanguageID = @LanguageID
	and		active =1
	and		TemplateDetailsID= @theTemplateDetailsID

set @DBError = @@error
if @DBError <> 0
	goto general_error


--**********************
--** update	EmailTemplates 
--**********************
set @Action = 'update	EmailTemplates '

-- update the email templates table..
update	EmailTemplates 
set		templatedescription = @inputDesc 
where	EmailTemplateID = @theEmailTemplateID

set @DBError = @@error
if @DBError <> 0
	goto general_error


--**********************
--** update	EmailTemplateDetails
--**********************
set @Action = 'update	EmailTemplateDetails'

-- update the existing template..
update	EmailTemplateDetails 
set		EmailFromDisplay = @inputFromDisplay,
		Subject = @inputSubject,
		EmailBody = @inputBody,
		UpdatedBy = @inputUpdatedBy,
		UpdateDateTS = getdate(),
		Active = @inputActive,
		DefaultTemplate = @inputDefaultTemplate,
		IncludeHeader = @inputIncHeader,
		IncludeFooter = @inputIncFooter
where	EmailTemplateID = @theEmailTemplateID
and		templateDetailsID = @theTemplateDetailsID
and		LanguageID = @LanguageID

set @DBError = @@error
if @DBError <> 0
	goto general_error



COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)
GO


GRANT EXECUTE ON [Admin_UpdateEmailTemplateForLanguageID] TO ExecuteOnlyRole

GO
