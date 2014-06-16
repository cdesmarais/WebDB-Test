if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetPasswordQuestions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetPasswordQuestions]
GO



CREATE PROCEDURE dbo.GetPasswordQuestions

AS
SET NOCOUNT ON
set transaction isolation level read uncommitted

Select PwdQuestionID as Password_Question_ID,Question 
from PasswordQuestion 
where PwdQuestionID not in (98,99)
GO

GRANT EXECUTE ON [GetPasswordQuestions] TO ExecuteOnlyRole

GO
