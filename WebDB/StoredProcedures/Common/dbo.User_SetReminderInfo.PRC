if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_SetReminderInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_SetReminderInfo]
GO

CREATE Procedure dbo.User_SetReminderInfo 
(
@Email nvarchar(255),
@Password_Question_ID int,
@Password_Answer nvarchar(255),
@retVal int OUTPUT
)
AS
SET NOCOUNT ON
Update Customer 
set PwdQuestionID = @Password_Question_ID
,PwdAnswer = @Password_Answer 
where Email = @Email 

if (@@ERROR <> 0) goto nogood
SELECT @retval= 1
RETURN(1)
nogood:
return (0)
GO


GRANT EXECUTE ON [User_SetReminderInfo] TO ExecuteOnlyRole

GO
