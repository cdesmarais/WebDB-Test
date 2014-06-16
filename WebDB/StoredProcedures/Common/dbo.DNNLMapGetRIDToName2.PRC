if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetRIDToName2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetRIDToName2]
GO

CREATE PROCEDURE dbo.DNNLMapGetRIDToName2
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
  WHERE NLRuleID = 8 AND (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY RID
)
ORDER BY RID
GO

GRANT EXECUTE ON [DNNLMapGetRIDToName2] TO ExecuteOnlyRole
GO