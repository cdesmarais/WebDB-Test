if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Restaurant_ListPaymentTypesByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Restaurant_ListPaymentTypesByID]
GO

--*** TODO: Consider wrapping this into a common function; this is identical to admin
CREATE Procedure dbo.Concierge_Restaurant_ListPaymentTypesByID
 (
  @RestaurantID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT		pt.PaymentType
FROM		PaymentTypes 
INNER JOIN	PaymentTypeVW pt
ON			PaymentTypes.PaymentTypeID = pt.PaymentTypeID
WHERE		(PaymentTypes.RID = @RestaurantID)

GO

GRANT EXECUTE ON [Concierge_Restaurant_ListPaymentTypesByID] TO ExecuteOnlyRole

GO
