IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[dbo].[DNNLMapGetNameToMetroMacroGeneric]') AND ObjectProperty(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[DNNLMapGetNameToMetroMacroGeneric]
GO

CREATE PROCEDURE dbo.DNNLMapGetNameToMetroMacroGeneric 
(  
  @MapFileGenDateTime datetime,
  @DomainId int  
)  
AS  
SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  
SELECT NLMapValue + ' ' +  NLMapKey
FROM  dbo.NLURLVw   
WHERE  
	NLDataID IN 
	(
		SELECT max(NLDataId)
		FROM 
			NLURLVw nlu  
				INNER JOIN metroarea ma ON nlu.metroareaid = ma.metroareaid    
					INNER JOIN domain d ON ma.supportedDomainId = d.DomainId     
		WHERE 
			NLRuleID IN (2,3) 
			AND 
			nlu.DataLastModifiedDt  <= @MapFileGenDateTime
			AND 
			d.DomainId = @DomainId   
		GROUP BY 
			NLRuleId, nlu.MetroAreaId, MacroID
	)  
ORDER BY NLRuleID,MetroAreaID,MacroID  
GO

GRANT EXECUTE ON [DNNLMapGetNameToMetroMacroGeneric] TO ExecuteOnlyRole
GO

