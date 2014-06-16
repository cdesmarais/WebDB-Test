if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Offer_ListWithRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Offer_ListWithRestaurants]
GO

CREATE Procedure dbo.Concierge_Offer_ListWithRestaurants
(
  @RestaurantID int
)
As
--***************************************
--** Legacy APIs called by go.concierge uses opentable.dll
--***************************************

SET NOCOUNT ON
set transaction isolation level read uncommitted

if @RestaurantID = 0
Begin
		SELECT Offers.RID AS RestaurantID
		,o.Offer AS OfferName
		FROM Offers 
		INNER JOIN RestaurantVW r
		ON	Offers.RID = r.RID
		INNER JOIN OfferLocal o
		ON Offers.offerID = o.offerID 
		and	r.LanguageID = o.LanguageID
		WHERE r.Allotment <> 1
		ORDER BY Offers.RID
		,o.Offer
End
if @RestaurantID > 0
Begin
		SELECT Offers.RID AS RestaurantID
		,o.Offer AS OfferName
		FROM Offers 
		INNER JOIN RestaurantVW r
		ON	Offers.RID = r.RID
		INNER JOIN OfferLocal o
		ON Offers.offerID = o.offerID 
		and	r.LanguageID = o.LanguageID
		WHERE Offers.RID = @RestaurantID 
		And r.Allotment <> 1
		ORDER BY o.Offer
End

GO


GRANT EXECUTE ON [Concierge_Offer_ListWithRestaurants] TO ExecuteOnlyRole

GO
