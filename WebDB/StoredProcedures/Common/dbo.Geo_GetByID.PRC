if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Geo_GetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Geo_GetByID]
GO


CREATE Procedure dbo.Geo_GetByID
 (
  @GeoID int
 )

As
SET NOCOUNT ON

SELECT			MetroAreaName               AS GeoName
				,m.Active,SearchLevel AS SearchLevel
				,Message             AS GeoText
				,ServerToLocalOffset as TimeZoneOffset
FROM			MetroAreaVW m
INNER JOIN		TimeZoneVW t 
ON				(t.TZID = m.TZID)
WHERE			(metroareaid = @GeoID)
GO

GRANT EXECUTE ON [Geo_GetByID] TO ExecuteOnlyRole

GO
