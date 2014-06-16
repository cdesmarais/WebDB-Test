if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserGetGeoIDByEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserGetGeoIDByEmail]
GO

CREATE Procedure dbo.UserGetGeoIDByEmail
 (
  @Email nvarchar(255),
  @retval int OUTPUT
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if exists(SELECT metroareaid AS MetroID FROM Customer WHERE (EMail = @Email) and ConsumerType = 8)
BEGIN
	SELECT @retval = metroareaid FROM Customer WHERE (EMail = @Email) and ConsumerType = 8
END
else
BEGIN
	Set @retval = 0
END

GO

GRANT EXECUTE ON [UserGetGeoIDByEmail] TO ExecuteOnlyRole

GO
