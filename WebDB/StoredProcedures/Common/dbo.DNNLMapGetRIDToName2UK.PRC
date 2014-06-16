if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetRIDToName2UK]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetRIDToName2UK]
GO

CREATE PROCEDURE dbo.DNNLMapGetRIDToName2UK
(
  @MapFileGenDateTime datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT NLMapKey + ' ' + NLMapValue
from		dbo.NLURLVw 
where		NLDataID in 
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

GRANT EXECUTE ON [DNNLMapGetRIDToName2UK] TO ExecuteOnlyRole
GO