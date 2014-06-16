if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PaymentTypes_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PaymentTypes_Delete]
GO


CREATE Procedure dbo.Admin_PaymentTypes_Delete
 (
  @RestaurantID int
 )
AS
SET NOCOUNT ON
DELETE FROM PaymentTypes
WHERE RID = @RestaurantID
GO

GRANT EXECUTE ON [Admin_PaymentTypes_Delete] TO ExecuteOnlyRole

GO
