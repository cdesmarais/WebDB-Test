if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheCountrySearchRadius]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheCountrySearchRadius]
GO
CREATE PROCEDURE [dbo].[DNCacheCountrySearchRadius]

as

SELECT RadiusLookupID,
	   CountryID,
	   Radius,
	   SortOrder, 
	   IsRadiusinMiles
From   CountrySearchRadiusLookup
Order by SortOrder

Go

GRANT EXECUTE ON [DNCacheCountrySearchRadius] TO ExecuteOnlyRole

Go