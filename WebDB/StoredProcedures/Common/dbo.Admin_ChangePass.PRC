if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ChangePass]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ChangePass]
GO

CREATE PROCEDURE dbo.Admin_ChangePass
 (
  @Password nvarchar(255),
  @UserName nvarchar(255)
 )
As

SET NOCOUNT ON

UPDATE Login
SET Password = @Password
WHERE UserName =  @UserName

GO

GRANT EXECUTE ON [Admin_ChangePass] TO ExecuteOnlyRole

GO
