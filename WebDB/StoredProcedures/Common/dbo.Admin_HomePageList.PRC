
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_HomePageList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_HomePageList]
GO


CREATE PROCEDURE dbo.Admin_HomePageList
 As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT  	StateID,   
   		StateName.CountryID,   
   		StateName,   
   	        'US' CountryName   
FROM  		StateName  
WHERE  		stateID != '  '  
AND		CountryID = 'US'
UNION ALL
SELECT DISTINCT '' StateID
		,sl.CountryID
		,'' StateName
		,c.CountryName 
FROM 		StateAreaListing sl
INNER JOIN 	CountryVW  c
ON 		sl.CountryID = c.CountryID
WHERE 		sl.CountryID <> 'US'
		AND sl.DomainID = 1
ORDER BY 	StateName
		,CountryName

GO

GRANT EXECUTE ON [Admin_HomePageList] TO ExecuteOnlyRole

GO
