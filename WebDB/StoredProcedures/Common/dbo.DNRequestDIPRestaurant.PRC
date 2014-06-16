if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRequestDIPRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRequestDIPRestaurant]
GO



CREATE PROCEDURE dbo.DNRequestDIPRestaurant
(
  @RestName nvarchar(255),
  @Metro_ID int,
  @isCaller int,
  @UserID int,
  @Email nvarchar(255),
  @City nvarchar(50),
  @State nvarchar(50)
)
AS

SET NOCOUNT ON
if @UserID = 0
BEGIN
Set @UserID = null
End

-- Set Metro Area ID = "No Metro"
if @Metro_ID = -1
BEGIN
Set @Metro_ID = 55
END

BEGIN TRANSACTION
if @isCaller = 1

BEGIN

Insert Into DIPRestaurantRequest
(
    RequestName,
    MetroID,
    CustomerID,
    CallerID,
    Sent,
    Email,   
    City,
    State
)
 Values
(
    @RestName,
    @Metro_ID,
    null,
    @UserID,
    0,
    @Email,    
    @City,
    @State
)

END

if @isCaller = 0

BEGIN

Insert Into DIPRestaurantRequest
(
    RequestName,
    MetroID,
    CustomerID,
    CallerID,
    Sent,
    Email,   
    City,
    State
)
 Values
(
    @RestName,
    @Metro_ID,
    @UserID,
    null,
    0,
    @Email,   
    @City,
    @State
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

GRANT EXECUTE ON [DNRequestDIPRestaurant] TO ExecuteOnlyRole

GO
