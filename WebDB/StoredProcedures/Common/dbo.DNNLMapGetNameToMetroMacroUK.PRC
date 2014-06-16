if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetNameToMetroMacroUK]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetNameToMetroMacroUK]
GO

CREATE PROCEDURE dbo.DNNLMapGetNameToMetroMacroUK
(
  @MapFileGenDateTime datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	NLMapValue + ' ' + NLMapKey
FROM		dbo.NLURLVw
where		NLDataID in 
(SELECT MAX(NLDataID) FROM NLURLVw
  WHERE NLRuleID in (2,3) AND MetroAreaID=72 AND (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY NLRuleID,MacroID
)
ORDER BY NLRuleID,MacroID
GO

GRANT EXECUTE ON [DNNLMapGetNameToMetroMacroUK] TO ExecuteOnlyRole
GO