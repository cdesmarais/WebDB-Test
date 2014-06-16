if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Offer_ListByRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Offer_ListByRestaurant]
GO

CREATE Procedure dbo.Admin_Offer_ListByRestaurant
 (
  @RestaurantID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		Offers.offerID AS OfferID
			,o.Offer
FROM		Offers 
INNER JOIN	OfferVW o 
ON			Offers.offerID = o.offerID
WHERE		(Offers.RID = @RestaurantID)

GO

GRANT EXECUTE ON [Admin_Offer_ListByRestaurant] TO ExecuteOnlyRole

GO
