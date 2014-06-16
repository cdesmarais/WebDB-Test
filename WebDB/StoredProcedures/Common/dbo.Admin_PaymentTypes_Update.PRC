if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PaymentTypes_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PaymentTypes_Update]
GO



CREATE PROCEDURE dbo.Admin_PaymentTypes_Update
 (
  @RestaurantID int,
  @PaymentTypeID int
 )
As
SET NOCOUNT ON
EXECUTE Admin_PaymentTypes_Delete @RestaurantID
EXECUTE Admin_PaymentTypes_Add @RestaurantID,@PaymentTypeID
GO

GRANT EXECUTE ON [Admin_PaymentTypes_Update] TO ExecuteOnlyRole

GO
