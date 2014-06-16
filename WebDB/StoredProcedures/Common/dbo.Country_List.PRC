if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Country_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Country_List]
GO




/****** Object:  Stored Procedure dbo.Country_List    Script Date: 2/7/2000 3:55:29 PM ******/
CREATE PROCEDURE dbo.Country_List
As
SET NOCOUNT ON
SELECT CountryID AS Abbreviation,CountryName AS CountryName
FROM CountryVW

ORDER BY CountryName
GO

GRANT EXECUTE ON [Country_List] TO ExecuteOnlyRole

GO
