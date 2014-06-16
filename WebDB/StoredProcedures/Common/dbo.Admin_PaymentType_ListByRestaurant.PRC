if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PaymentType_ListByRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PaymentType_ListByRestaurant]
GO

CREATE Procedure dbo.Admin_PaymentType_ListByRestaurant
 (
  @RestaurantID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		PaymentTypes.PaymentTypeID AS PaymentTypeID
			,pt.PaymentType
FROM		PaymentTypes 
INNER JOIN  PaymentTypeVW pt 
ON			PaymentTypes.PaymentTypeID = pt.PaymentTypeID
WHERE		(PaymentTypes.RID = @RestaurantID)

GO

GRANT EXECUTE ON [Admin_PaymentType_ListByRestaurant] TO ExecuteOnlyRole

GO
