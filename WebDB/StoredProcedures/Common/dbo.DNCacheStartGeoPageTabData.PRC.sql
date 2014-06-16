-- FILE: dbo.DNCacheStartGeoPageTabData.PRC for WR2011-R4S2

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheStartGeoPageTabData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.DNCacheStartGeoPageTabData
GO

-- DNCacheStartPageGeoTabData:
-- Used to populate CTabsetData for tab type 5 - most covers by neighborhood


CREATE PROCEDURE dbo.DNCacheStartGeoPageTabData
AS

-- Max number of RID's to include per neighborhood
DECLARE @LimitPerNbhd INT = 10

SELECT 
	rrank.*
	
FROM
	(
	SELECT
				r.NeighborhoodID
				,5 AS StartPageTabTypeID   -- StartPageTabType 5 = "MostBookedCovers" 
				,ROW_NUMBER() OVER 
					(
						PARTITION BY r.NeighborhoodID 
						ORDER BY covers.TotalSeatedStandardCovers DESC
					) AS NeighborhoodRank
				,r.RID
	FROM		RestaurantVW r
	INNER JOIN	RestaurantCoverCounts covers 
	ON			(r.RID = covers.RID)
	INNER JOIN	NeighborhoodVW n
	ON			(r.NeighborhoodID = n.NeighborhoodID)
	WHERE		r.RestStateID in (1,13,16)
	AND			n.Active = 1
	) 
	AS rrank
	
WHERE 
	rrank.NeighborhoodRank <= @LimitPerNbhd
	
GO

GRANT EXECUTE ON DNCacheStartGeoPageTabData TO ExecuteOnlyRole
GO
