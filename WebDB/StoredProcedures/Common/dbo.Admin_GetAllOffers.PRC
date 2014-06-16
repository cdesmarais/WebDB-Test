if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetAllOffers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetAllOffers]
GO

CREATE Procedure dbo.Admin_GetAllOffers
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @Languages AS int
Select @Languages = count(DISTINCT LanguageID) from offerLocal


SELECT		offerID AS OfferID
		,Offer as Value
		,@Languages as Languages
FROM		OfferVW
order by	Offer
GO


GRANT EXECUTE ON [dbo].[Admin_GetAllOffers] TO ExecuteOnlyRole

GO
