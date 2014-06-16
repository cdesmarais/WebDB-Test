if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdateHeaderFooter]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdateHeaderFooter]
GO

-- Save header/footer information
CREATE PROCEDURE dbo.Admin_UpdateHeaderFooter
(
	@theHeader nvarchar(4000),
	@theFooter nvarchar(4000)
)
As
SET NOCOUNT ON

BEGIN TRANSACTION
declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @id int

set @ProcName = 'Admin_UpdateHeaderFooter'
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
--** Update Header
--**********************
set @Action = 'update	emailtemplateelements Header'

update	emailtemplateelements 
set		elementdata = @theHeader 
where	emailelementtype='Header'
and		LanguageID = @LanguageID

set @DBError = @@error
if @DBError <> 0
	goto general_error


--**********************
--** Update Header
--**********************
set @Action = 'update	emailtemplateelements Footer'
	
update	emailtemplateelements 
set		elementdata = @theFooter 
where	emailelementtype='Footer'
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


GRANT EXECUTE ON [Admin_UpdateHeaderFooter] TO ExecuteOnlyRole

GO
