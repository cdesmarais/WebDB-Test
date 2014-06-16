if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetNameToRIDUK]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetNameToRIDUK]
GO

CREATE PROCEDURE dbo.DNNLMapGetNameToRIDUK
(
  @MapFileGenDateTime datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		NLMapValue + ' ' + NLMapKey
FROM		dbo.NLURLVw 
where		NLDataID in 
(SELECT MAX(NLDataID) FROM NLURLVw nlv
  INNER JOIN  Restaurant r
  ON nlv.RID = r.RID
  INNER JOIN  Neighborhood n
  ON  r.NeighborhoodID = n.NeighborhoodID
  WHERE NLRuleID = 1 AND n.MetroAreaID= 72 AND  (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY nlv.RID
)
ORDER BY RID
GO

GRANT EXECUTE ON [DNNLMapGetNameToRIDUK] TO ExecuteOnlyRole
GO