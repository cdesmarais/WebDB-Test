if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetMetroMacroToNameUK]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetMetroMacroToNameUK]
GO

CREATE PROCEDURE dbo.DNNLMapGetMetroMacroToNameUK
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
  WHERE NLRuleID in (2,3) AND MetroAreaID=72 AND (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY NLRuleID,MacroID
)
ORDER BY NLRuleID,MetroAreaID,MacroID
GO

GRANT EXECUTE ON [DNNLMapGetMetroMacroToNameUK] TO ExecuteOnlyRole
GO