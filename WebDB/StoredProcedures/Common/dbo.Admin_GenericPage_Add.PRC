if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GenericPage_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GenericPage_Add]
GO


CREATE Procedure dbo.Admin_GenericPage_Add
 (
  @Name nvarchar(50),
  @Content ntext,
  @LastUpdatedBy nvarchar(255)
 )
As


BEGIN TRANSACTION
declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @PageID int

--**********************
--** Get Language
--**********************
set @Action = 'Retrieve LanguageID'

set @DBError = @@error
if @DBError <> 0
	goto general_error


--**********************
--** Insert into Master
--**********************
set @Action = 'INSERT INTO GenericPage'

INSERT INTO GenericPage
 (
  Active
 )
VALUES
 (
  1
 )
set @DBError = @@error
set @PageID = scope_identity()
if @DBError <> 0
	goto general_error

--**********************
--** Insert into Local
--**********************
set @Action = 'INSERT INTO GenericPageLocal'

INSERT INTO GenericPageLocal
 (
	PageID,
	Name,
	Content,
	LastUpdatedBy,
	LanguageID,
	UpdatedDate
 )
 Select @PageID as PageID,
	@Name as  Name,  
	@Content as Content, 
	@LastUpdatedBy as LastUpdatedBy,
	LanguageID,
	getdate() as UpdatedDate
from 	[Language] 
WHERE 	active = 1

 
 
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

 
 
GO

GRANT EXECUTE ON [Admin_GenericPage_Add] TO ExecuteOnlyRole

GO
