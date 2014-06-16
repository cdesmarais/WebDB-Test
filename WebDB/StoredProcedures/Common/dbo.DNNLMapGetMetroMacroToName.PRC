if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetMetroMacroToName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetMetroMacroToName]
GO

CREATE PROCEDURE dbo.DNNLMapGetMetroMacroToName
(
  @MapFileGenDateTime datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT NLMapKey + ' ' + NLMapValue
from		dbo.NLURLVw 
where		NLDataID in 
(SELECT MAX(NLDataID) FROM NLURLVw
  WHERE NLRuleID in (2,3) AND (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY NLRuleID,MetroAreaID,MacroID
)
ORDER BY NLRuleID,MetroAreaID,MacroID
GO


GRANT EXECUTE ON [DNNLMapGetMetroMacroToName] TO ExecuteOnlyRole
GO