if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllOffers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllOffers]
GO

CREATE procedure [dbo].[Admin_CacheAllOffers] 
AS
SET NOCOUNT ON

SELECT	OfferID,
	Offer, 
	LanguageID
FROM	OfferAVW
Order by Offer


GO

GRANT EXECUTE ON [Admin_CacheAllOffers] TO ExecuteOnlyRole
GO