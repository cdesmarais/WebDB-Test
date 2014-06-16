if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantImporter_GetAllAdditionalDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantImporter_GetAllAdditionalDetails]
GO

CREATE Procedure dbo.RestaurantImporter_GetAllAdditionalDetails

As

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	Offers.RID
		,o.offerID
		,o.Offer AS OfferName
		,o.LanguageID
FROM		Offers 
INNER JOIN 	OfferLocal o
ON		Offers.offerID = o.offerID
inner join	RestaurantAVW r
on			Offers.RID = r.RID
and			o.LanguageID = r.LanguageId


GO





GRANT EXECUTE ON [dbo].[RestaurantImporter_GetAllAdditionalDetails] TO ExecuteOnlyRole

GO
