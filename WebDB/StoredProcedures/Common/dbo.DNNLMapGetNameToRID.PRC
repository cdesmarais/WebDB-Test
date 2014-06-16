if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetNameToRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetNameToRID]
GO

CREATE PROCEDURE dbo.DNNLMapGetNameToRID
(
  @MapFileGenDateTime datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		NLMapValue + ' ' + NLMapKey
FROM		dbo.NLURLVw
where		NLDataID in 
(SELECT MAX(NLDataID) FROM NLURLVw
  WHERE NLRuleID = 1 AND (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY RID
)
ORDER BY RID
GO

GRANT EXECUTE ON [DNNLMapGetNameToRID] TO ExecuteOnlyRole
GO