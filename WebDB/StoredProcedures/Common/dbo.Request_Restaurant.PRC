if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Request_Restaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Request_Restaurant]
GO


CREATE PROCEDURE dbo.Request_Restaurant
(
  @RestName nvarchar(255),
  @Metro_ID int,
  @isCaller int,
  @UserID int,
  @Email nvarchar(50),
  @Comments nvarchar(255)
)
AS

SET NOCOUNT ON
if @UserID = 0
BEGIN
Set @UserID = null
End

BEGIN TRANSACTION
if @isCaller = 1

BEGIN

Insert Into RestaurantRequest
(
    RequestName,
    MetroID,
    CustomerID,
    CallerID,
    Sent,
    Email,
    Comments
)
 Values
(
    @RestName,
    @Metro_ID,
    null,
    @UserID,
    0,
    @Email,
    @Comments
)

END

if @isCaller = 0

BEGIN

Insert Into RestaurantRequest
(
    RequestName,
    MetroID,
    CustomerID,
    CallerID,
    Sent,
    Email,
    Comments
)
 Values
(
    @RestName,
    @Metro_ID,
    @UserID,
    null,
    0,
    @Email,
    @Comments
)

END


if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Request_Restaurant] TO ExecuteOnlyRole

GO
