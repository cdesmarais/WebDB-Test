if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllPriceQuartiles]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllPriceQuartiles]
GO

CREATE procedure [dbo].[Admin_CacheAllPriceQuartiles]

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT	PriceQuartileID,
	PriceQuartile, 
	countryID,
	LanguageID
FROM	PriceQuartileAVW
Order by PriceQuartileID


GO

GRANT EXECUTE ON [Admin_CacheAllPriceQuartiles] TO ExecuteOnlyRole
GO