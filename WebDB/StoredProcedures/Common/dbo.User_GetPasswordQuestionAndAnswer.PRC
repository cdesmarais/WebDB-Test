if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_GetPasswordQuestionAndAnswer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_GetPasswordQuestionAndAnswer]
GO

CREATE Procedure dbo.User_GetPasswordQuestionAndAnswer
 (
  @Email nvarchar(255),
  @IsCaller int=0
 )
As


SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if(@IsCaller=0)
Begin
	select 
		Customer.email as email,
		'' as password,
		Customer.PwdQuestionID as password_question_id,
		Customer.PwdAnswer as password_answer,
		PasswordQuestion.question as password_question_value,cast(Active as int) as Status
from Customer 
INNER JOIN PasswordQuestion 
	on Customer.PwdQuestionID = PasswordQuestion.PwdQuestionID
where Customer.email = @Email and ConsumerType <> 8
End

if(@IsCaller<>0)
Begin
	select 
		Caller.LoginName as email,
		'' as password,
		Caller.PwdQuestionID as password_question_id,
		Caller.PwdAnswer as password_answer,
		PasswordQuestion.question as password_question_value,callerstatusid as Status
	from Caller
	INNER JOIN PasswordQuestion 
	on Caller.PwdQuestionID = PasswordQuestion.PwdQuestionID
	where Caller.LoginName = @Email and ConsumerType <> 8
End

GO

GRANT EXECUTE ON [User_GetPasswordQuestionAndAnswer] TO ExecuteOnlyRole

GO
