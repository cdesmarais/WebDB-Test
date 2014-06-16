if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetNameToMacroNeighborhood]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetNameToMacroNeighborhood]
GO

CREATE PROCEDURE dbo.DNNLMapGetNameToMacroNeighborhood
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
  WHERE NLRuleID in (11,12) AND (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY NLRuleID,MacroID,NeighborhoodID
)
ORDER BY NLRuleID,MacroID,NeighborhoodID
GO

GRANT EXECUTE ON [DNNLMapGetNameToMacroNeighborhood] TO ExecuteOnlyRole
GO
