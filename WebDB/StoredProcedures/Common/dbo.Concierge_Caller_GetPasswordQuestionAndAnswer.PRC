if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_GetPasswordQuestionAndAnswer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_GetPasswordQuestionAndAnswer]
GO

CREATE PROCEDURE dbo.Concierge_Caller_GetPasswordQuestionAndAnswer
 (
  @login nvarchar(255)
 )
As
SET NOCOUNT ON
select 
	Caller.LoginName as login,
	'' as password,
	Caller.PwdQuestionID as password_question_id,
	Caller.PwdAnswer as password_answer,
	PasswordQuestion.question as password_question_value
from Caller 
INNER JOIN PasswordQuestion 
	on Caller.PwdQuestionID = PasswordQuestion.PwdQuestionID
	where Caller.LoginName = @Login
and PositionID = 2

GO

GRANT EXECUTE ON [Concierge_Caller_GetPasswordQuestionAndAnswer] TO ExecuteOnlyRole

GO
