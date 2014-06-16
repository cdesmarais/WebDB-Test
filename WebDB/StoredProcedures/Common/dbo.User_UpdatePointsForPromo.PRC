if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_UpdatePointsForPromo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_UpdatePointsForPromo]
GO



CREATE Procedure dbo.User_UpdatePointsForPromo
(
  @CustomerID int,
  @CallerID int,
  @Points int
)
AS
SET NOCOUNT ON
declare @n int

BEGIN TRANSACTION
if @CallerID = 0
	Begin
	If Not Exists(Select CustID From Customer Where CustID = @CustomerID) Goto invalid_user

	SELECT @n= COUNT(*) FROM PromoUse Inner Join Promos On PromoUse.PromoID = Promos.PromoID Where code='FRIENDREF' And CustID = @CustomerID
	If (@n > 24) Goto promo_max

	Update Customer
	Set Points = Points + @Points
	Where CustID = @CustomerID
              IF (@@ERROR <> 0) Goto error
	End
if @CallerID > 0
	Begin
	If Not Exists(Select CallerID From Caller Where CallerID = @CallerID) Goto invalid_user

	SELECT @n= COUNT(*) FROM PromoUse Inner Join Promos On PromoUse.PromoID = Promos.PromoID Where code='FRIENDREF' And CallerID = @CallerID
	If (@n > 24) Goto promo_max

	Update Caller
	Set Points = Points + @Points
	Where CallerID = @CallerID
              IF (@@ERROR <> 0) Goto error
	End

        COMMIT TRANSACTION
        Return(0)

error:
   BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('89',17,1)
         RETURN(1)
      END

invalid_user:
   BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('32',17,1)
         RETURN(2)
      END

promo_max:
   BEGIN
         ROLLBACK TRANSACTION
         RAISERROR ('90',1,1)
         RETURN(3)
      END
GO

GRANT EXECUTE ON [User_UpdatePointsForPromo] TO ExecuteOnlyRole

GO
