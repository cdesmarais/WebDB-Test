if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetName2ToRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetName2ToRID]
GO

CREATE PROCEDURE dbo.DNNLMapGetName2ToRID
(
  @MapFileGenDateTime datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		NLMapValue + ' ' + NLMapKey
FROM		dbo.NLURLVw
WHERE		NLDataID IN 
(SELECT MAX(NLDataID) FROM NLURLVw
  WHERE NLRuleID = 8 AND (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY RID
)
ORDER BY RID
GO

GRANT EXECUTE ON [DNNLMapGetName2ToRID] TO ExecuteOnlyRole
GO