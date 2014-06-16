if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConDNCacheRestaurantInfoForTTConnect]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConDNCacheRestaurantInfoForTTConnect]
GO

CREATE PROCEDURE dbo.[OTConDNCacheRestaurantInfoForTTConnect]

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--
-- Retreive WebDB Restaurants for TTConnect (BrandID = 2)
--

EXEC	procOTConDNCacheRestaurantInfoForBrandID @BrandID=2


GO

GRANT EXECUTE ON [OTConDNCacheRestaurantInfoForTTConnect] TO ConsoleExecuteRole

GO
