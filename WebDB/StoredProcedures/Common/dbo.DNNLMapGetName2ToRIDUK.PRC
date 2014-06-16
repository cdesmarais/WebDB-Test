if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetName2ToRIDUK]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetName2ToRIDUK]
GO

CREATE PROCEDURE dbo.DNNLMapGetName2ToRIDUK
(
  @MapFileGenDateTime datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		NLMapValue + ' ' + NLMapKey
FROM		dbo.NLURLVw
WHERE 		NLDataID IN 
(SELECT MAX(NLDataID) FROM NLURLVw nlv
  INNER JOIN  Restaurant r
  ON nlv.RID = r.RID
  INNER JOIN  Neighborhood n
  ON  r.NeighborhoodID = n.NeighborhoodID
  WHERE NLRuleID = 8 AND n.MetroAreaID= 72 AND  (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY nlv.RID
)
ORDER BY RID
GO

GRANT EXECUTE ON [DNNLMapGetName2ToRIDUK] TO ExecuteOnlyRole
GO