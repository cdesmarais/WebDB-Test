if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserGetUserIDByEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserGetUserIDByEmail]
GO

CREATE PROCEDURE dbo.DNUserGetUserIDByEmail
 (
  @Email nvarchar(255)
 )
As

SET NOCOUNT ON
SELECT CustID AS UserID
FROM Customer
WHERE (EMail = @Email) --and ConsumerType <> 8
GO

GRANT EXECUTE ON [DNUserGetUserIDByEmail] TO ExecuteOnlyRole

GO
