if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Geo_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Geo_List]
GO




CREATE Procedure dbo.Geo_List
As

SET NOCOUNT ON

SELECT		metroareaid 		 AS GeoID
			,MetroAreaName AS GeoName
FROM        MetroAreaVW
WHERE		(Active = 1)
ORDER BY	MetroAreaName
GO

GRANT EXECUTE ON [Geo_List] TO ExecuteOnlyRole

GO
