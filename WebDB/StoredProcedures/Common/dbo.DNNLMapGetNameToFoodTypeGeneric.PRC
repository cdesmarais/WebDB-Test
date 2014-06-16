IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[dbo].[DNNLMapGetNameToFoodTypeGeneric]') AND ObjectProperty(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[DNNLMapGetNameToFoodTypeGeneric]
GO

CREATE PROCEDURE dbo.DNNLMapGetNameToFoodTypeGeneric  
(    
  @MapFileGenDateTime datetime,  
  @DomainId int  
)    
AS    
SET NOCOUNT ON    
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
    
SELECT  NLMapValue + ' ' + NLMapKey     
FROM  dbo.NLURLVw    
WHERE   NLDataID  in     
(  
SELECT MAX(nlu.NLDataID) FROM NLURLVw nlu  
  inner join metroarea ma on nlu.metroareaid = ma.metroareaid  
  inner join domain d on ma.supportedDomainId = d.DomainId   
  WHERE nlu.NLRuleID = 7    
        AND (nlu.DataLastModifiedDt  <= @MapFileGenDateTime)   
            AND d.domainid = @DomainId    
  GROUP BY nlu.MetroAreaID,nlu.FoodTypeID    
)    
ORDER BY MetroAreaID,FoodTypeID    

GO

GRANT EXECUTE ON [DNNLMapGetNameToFoodTypeGeneric] TO ExecuteOnlyRole
GO