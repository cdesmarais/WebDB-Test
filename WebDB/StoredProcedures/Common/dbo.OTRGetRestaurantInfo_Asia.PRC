

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[OTRGetRestaurantInfo_Asia]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[OTRGetRestaurantInfo_Asia]
GO
CREATE PROCEDURE [dbo].[OTRGetRestaurantInfo_Asia]  
AS
BEGIN
	/* Stored procedure that gets restaurant details from WebDB and ROMS */
	SELECT  RID as RID, 50000+ RID AS ROMSID, RName AS ResoRname
	FROM RestaurantVW 
END
GO

GRANT EXECUTE ON [dbo].[OTRGetRestaurantInfo_Asia] TO ExecuteOnlyRole
GO

