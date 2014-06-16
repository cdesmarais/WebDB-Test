

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_JobAdd1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_JobAdd1]
GO

create procedure dbo.Admin_JobAdd1
(
	@Job_department_ID int,
	@Job_position_title nvarchar(100),
	@Job_position_location nvarchar(100),
	@Job_position_description ntext,
	@Job_Contact_Mail nvarchar(100),
	@Job_Contact_Name nvarchar(100),
	@Job_AppURL nvarchar(250),
	@Job_responsibilities ntext,
	@Job_requirements ntext,
	@Job_desired ntext,
	@Job_active bit,
	@Entry_date datetime
)

AS
SET NOCOUNT ON

BEGIN TRANSACTION

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @ID int

set @ProcName = 'JobsOnline'

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
--** Insert into Master Table
--**********************
set @Action = 'INSERT INTO JobsOnline'


Insert into 
	JobsOnline
	(
		JobDeptID
		,JobPositionTitle
		,JobPositionLocation
		,JobPositionDescription
		,JobContactMail
		,JobContactName
		,JobAppUrl
		,JobResponsibilities
		,JobRequirements
		,JobDesired
		,JobActive
		,EntryDate
		,LanguageID
	) 
values
	(
		@Job_department_ID
		,@Job_position_title
		,@Job_position_location
		,@Job_position_description
		,@Job_Contact_Mail
		,@Job_Contact_Name
		,@Job_AppURL
		,@Job_responsibilities
		,@Job_requirements
		,@Job_desired
		,@Job_active
		,@Entry_date
		,@LanguageID
	)

if (@@ERROR <> 0)
goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)
GO

GRANT EXECUTE ON [Admin_JobAdd1] TO ExecuteOnlyRole

GO

