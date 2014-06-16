

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[OTRGetRestaurantInfo]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[OTRGetRestaurantInfo]
GO
CREATE PROCEDURE [dbo].[OTRGetRestaurantInfo]  
AS
BEGIN
	/* Stored procedure that gets restaurant details from WebDB and ROMS */
	SELECT  r.RID as RID, g.RestaurantID AS ROMSID, r.RName AS ResoRname
	FROM RestaurantVW r 
	INNER JOIN (SELECT webid, RestaurantID FROM yellowstone.god.dbo.OTRPAccountvw 
	WHERE IsNumeric(webid)=1) g on g.WebID = r.RID 

END
GO

GRANT EXECUTE ON [dbo].[OTRGetRestaurantInfo] TO ExecuteOnlyRole
GO

