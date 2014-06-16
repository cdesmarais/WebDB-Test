if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_GetAllEmails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_GetAllEmails]
GO

CREATE Procedure dbo.User_GetAllEmails
 
As
/*revised for new schema 8/5/2003 --JD*/
SET NOCOUNT ON
SELECT email FROM Customer where Active = 1 and right(email,11) <> 'DEACTIVATED' and right(email,8) <> 'isAAUser'
union
SELECT email FROM Caller where callerstatusID = 1 and right(email,9) <> '~ottravel'
GO

GRANT EXECUTE ON [User_GetAllEmails] TO ExecuteOnlyRole

GO
