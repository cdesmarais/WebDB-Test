if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePrices]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePrices]
GO




CREATE PROCEDURE dbo.DNCachePrices
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT 	[PriceQuartileID], 
	[CountryID], 
	[LanguageID], 
	PriceQuartile [description],
	[Symbols]
FROM 	[PriceQuartileVW]

GO


GRANT EXECUTE ON [DNCachePrices] TO ExecuteOnlyRole

GO

