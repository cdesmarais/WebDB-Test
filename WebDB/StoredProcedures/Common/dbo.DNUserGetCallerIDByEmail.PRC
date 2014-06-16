if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserGetCallerIDByEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserGetCallerIDByEmail]
GO

CREATE PROCEDURE dbo.DNUserGetCallerIDByEmail
 (
  @Email nvarchar(255)
 )
As

SET NOCOUNT ON
SELECT CallerID AS UserID
FROM Caller
WHERE (LoginName = @Email) AND PositionID=3
GO

GRANT EXECUTE ON [DNUserGetCallerIDByEmail] TO ExecuteOnlyRole

GO
