if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantOffers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantOffers]
GO


/*
This proc is used by OT_MgrCache/StoredProcTab.cs in ConsumerSite to fetch data for WebCache
*/
CREATE Procedure dbo.DNCacheRestaurantOffers

As

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	Offers.RID
		,o.offerID
   		,o.Offer AS OfferName
FROM		Offers 
INNER JOIN 	OfferVW o
ON		Offers.offerID = o.offerID
inner join	Restaurant r
on			Offers.RID = r.RID
where		r.RestStateID != 4  -- Do not retrieve data for inactive restaurants

GO





GRANT EXECUTE ON [dbo].[DNCacheRestaurantOffers] TO ExecuteOnlyRole

GO
