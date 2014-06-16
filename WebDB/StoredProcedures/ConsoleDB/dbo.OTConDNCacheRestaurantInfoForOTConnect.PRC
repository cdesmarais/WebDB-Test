if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConDNCacheRestaurantInfoForOTConnect]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConDNCacheRestaurantInfoForOTConnect]
GO

CREATE PROCEDURE dbo.[OTConDNCacheRestaurantInfoForOTConnect]

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--
-- Retreive WebDB Restaurants for OTConnect (BrandID = 1)
--

EXEC	procOTConDNCacheRestaurantInfoForBrandID @BrandID=1


GO

GRANT EXECUTE ON [OTConDNCacheRestaurantInfoForOTConnect] TO ConsoleExecuteRole

GO
