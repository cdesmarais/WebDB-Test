---  This stored proc is being deprecated as of 2012WR4
IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[dbo].[DNNLMapGetRIDToNameMigratedToUK]') AND ObjectProperty(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[DNNLMapGetRIDToNameMigratedToUK]
GO

CREATE PROCEDURE dbo.DNNLMapGetRIDToNameMigratedToUK  
(  
  @MapFileGenDateTime datetime  
)  
AS  
SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  
SELECT NLMapKey + ' ' + NLMapValue  
from  dbo.NLURLVw   
where  NLDataID in   
(SELECT MAX(NLDataID) FROM NLURLVw nlv  
	INNER JOIN  Restaurant r  
			ON nlv.RID = r.RID and r.reststateid = 17
		INNER JOIN  Neighborhood n  
				ON  r.NeighborhoodID = n.NeighborhoodID  
  WHERE NLRuleID = 1 AND n.MetroAreaID= 72 AND  (DataLastModifiedDt  <= @MapFileGenDateTime)  
  GROUP BY nlv.RID  
)  
ORDER BY RID  

GO

GRANT EXECUTE ON [DNNLMapGetRIDToNameMigratedToUK] TO ExecuteOnlyRole
GO