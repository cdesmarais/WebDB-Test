if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_SetReminderInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_SetReminderInfo]
GO


CREATE PROCEDURE dbo.Concierge_Caller_SetReminderInfo 
(
@Login nvarchar(255),
@Password_Question_ID int,
@Password_Answer nvarchar(255),
@retVal int OUTPUT
)
AS 

SET NOCOUNT ON

Update Caller
set  PwdQuestionID = @Password_Question_ID
,PwdAnswer = @Password_Answer 
where LoginName = @Login

if (@@ERROR <> 0) goto nogood
SELECT @retval= 1
RETURN(1)
nogood:
return (0)

GO

GRANT EXECUTE ON [Concierge_Caller_SetReminderInfo] TO ExecuteOnlyRole

GO
