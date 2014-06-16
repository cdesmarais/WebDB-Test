---  This stored proc is being deprecated as of 2012WR4

IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[dbo].[DNNLMapGetMetroMacroToNameMigratedToUK]') AND ObjectProperty(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[DNNLMapGetMetroMacroToNameMigratedToUK]
GO

CREATE PROCEDURE dbo.DNNLMapGetMetroMacroToNameMigratedToUK  
(  
  @MapFileGenDateTime datetime  
)  
AS  
SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  
SELECT nl.NLMapKey + ' ' + nl.NLMapValue  
from  dbo.NLURLVw nl  
where  nl.NLDataID in   
(SELECT MAX(NLDataID) FROM NLURLVw nlu
  WHERE nlu.NLRuleID in (2,3) AND nlu.MetroAreaID=72 AND (nlu.DataLastModifiedDt  <= @MapFileGenDateTime)  
  GROUP BY nlu.NLRuleID,nlu.MacroID  
) 
ORDER BY nl.NLRuleID,nl.MetroAreaID,nl.MacroID  
GO

GRANT EXECUTE ON [DNNLMapGetMetroMacroToNameMigratedToUK] TO ExecuteOnlyRole
GO