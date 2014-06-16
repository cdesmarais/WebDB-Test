-- FILE: dbo.DNCacheStartGeoMacroData.PRC for WR2011_R5_TT46356

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheStartGeoMacroData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.DNCacheStartGeoMacroData
GO

-- DNCacheStartPageGeoTabData:
-- Used to populate CTabsetData for tab type 5 - most covers by macro neighborhood

CREATE PROCEDURE dbo.DNCacheStartGeoMacroData
AS
-- Max number of RID's to display on start geo page most booked tab per macro
DECLARE @LimitPerMacro INT = 50  -- driven by valuelookup

SELECT	@LimitPerMacro = [ValueInt] 
FROM 	ValueLookup 
WHERE	LType='WEBSERVER' AND LKey='StartGeoMaxMostBookedRIDs'

SELECT 
	rrank.*
FROM
	(
		SELECT
			m.MacroID 
			,5 AS StartPageTabTypeID   -- StartPageTabType 5 = "MostBookedCovers" 
			,ROW_NUMBER() OVER 
				(
					PARTITION BY m.MacroID  
					ORDER BY covers.TotalSeatedStandardCovers DESC
				) AS MacroRank
			,r.RID
		FROM		RestaurantVW r
		INNER JOIN	RestaurantCoverCounts covers 
		ON			(r.RID = covers.RID)
		INNER JOIN	NeighborhoodVW n  
		ON			(r.NeighborhoodID = n.NeighborhoodID)  
		INNER JOIN	dbo.MacroNeighborhoodVW m
		ON			(n.MacroID = m.MacroID)
		WHERE		r.RestStateID in (1,13,16)
		AND			m.Active = 1	
		AND			n.Active = 1
	) 
	AS rrank
WHERE 
	rrank.MacroRank <= @LimitPerMacro	
GO

GRANT EXECUTE ON DNCacheStartGeoMacroData TO ExecuteOnlyRole
GO

