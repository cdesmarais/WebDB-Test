if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Admin_Restaurant_GetAllMapLinkTemplates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].Admin_Restaurant_GetAllMapLinkTemplates
GO

Create procedure dbo.Admin_Restaurant_GetAllMapLinkTemplates

AS

--****************************************
--Get Maplink templates from Country Table under WebDB.
--****************************************

SELECT distinct CountryID, MapLink, AddressFormat 
FROM dbo.CountryAVW c
INNER JOIN dbo.Domain d
ON d.PrimaryLanguageID = c.LanguageID
INNER JOIN dbo.DBUser u
ON d.DomainID = u.DomainID
WHERE MapLink IS NOT NULL AND u.DBUser = user

GO

GRANT EXECUTE ON Admin_Restaurant_GetAllMapLinkTemplates TO ExecuteOnlyRole

GO

