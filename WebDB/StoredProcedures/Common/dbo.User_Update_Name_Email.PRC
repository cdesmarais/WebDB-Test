if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Update_Name_Email]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Update_Name_Email]
GO



CREATE Procedure dbo.User_Update_Name_Email
@UserID			int,
@isCaller		int,
@First_Name		nvarchar(255),
@Last_Name		nvarchar(255),
@Email			nvarchar(255)


AS
if @isCaller = 1
BEGIN
UPDATE Caller
SET FName = @First_Name,
	LName = @Last_Name,
	Email = @Email
WHERE CallerID = @UserID


END
else
BEGIN

UPDATE Customer
SET FName = @First_Name,
	LName = @Last_Name,
	Email = @Email
WHERE CustID = @UserID

END
GO

GRANT EXECUTE ON [User_Update_Name_Email] TO ExecuteOnlyRole

GO
