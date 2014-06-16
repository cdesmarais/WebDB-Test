if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FindRest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FindRest]
GO

CREATE PROCEDURE dbo.Admin_FindRest
AS

SET nocount on 
SET TRANSACTION isolation  LEVEL  READ  uncommitted 

SELECT   
  rid AS restaurantid,  
  rname AS restaurantname,  
  rsname AS restaurantsname,  
  reststateid,  
  n.[metroareaid],   
  r.[LanguageID],  
  [MetroAreaName],  
  d.Domain,  
  d.DomainID,  
  Len(rname) as LenRName  
FROM       
  [restaurantavw] r  
  INNER JOIN [NeighborhoodAVW] n  
 ON r.[neighborhoodid] = n.[neighborhoodid]  
 AND r.[LanguageID] = n.[LanguageID]  
  INNER JOIN [MetroAreaAVW] m  
 ON n.[MetroAreaID] = m.[MetroAreaID]  
 AND n.[LanguageID] = m.[LanguageID]  
  INNER JOIN Domain d  
 ON r.domainid = d.[DomainID]  
 AND r.[LanguageID] = d.[PrimaryLanguageID]  


GO


GRANT EXECUTE ON [Admin_FindRest] TO ExecuteOnlyRole

GO

