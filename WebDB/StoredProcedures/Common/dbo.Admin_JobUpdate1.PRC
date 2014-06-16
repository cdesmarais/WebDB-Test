

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_JobUpdate1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_JobUpdate1]
GO

create procedure dbo.Admin_JobUpdate1
(
	@Job_department_ID int,
	@Job_position_title nvarchar(100),
	@Job_position_location nvarchar(100),
	@Job_position_description ntext,
	@Job_Contact_Mail nvarchar(100),
	@Job_Contact_Name nvarchar(100),
	@Job_AppUrl nvarchar(250),
	@Job_responsibilities ntext,
	@Job_requirements ntext,
	@Job_desired ntext,
	@Job_active bit,
	@Job_ID int
)

AS
SET NOCOUNT ON

BEGIN TRANSACTION

update 
	JobsOnline 
set 
	JobDeptID=@Job_department_ID,
	JobPositionTitle=@Job_position_title,
	JobPositionLocation=@Job_position_location,
	JobResponsibilities=@Job_responsibilities,
	JobRequirements=@Job_requirements,
	JobDesired=@Job_desired,
	JobAppUrl=@Job_AppUrl,
	JobContactName=@Job_Contact_Name,
	JobContactMail=@Job_Contact_Mail,
	JobPositionDescription=@Job_position_description,
	JobActive=@Job_active
where
	JobID=@Job_ID

if (@@ERROR <> 0)
goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
ROLLBACK TRANSACTION
Return(0)

GO

GRANT EXECUTE ON [Admin_JobUpdate1] TO ExecuteOnlyRole

GO
