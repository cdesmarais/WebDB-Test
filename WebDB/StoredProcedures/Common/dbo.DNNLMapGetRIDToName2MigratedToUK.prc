---  This stored proc is being deprecated as of 2012WR4
IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[dbo].[DNNLMapGetRIDToName2MigratedToUK]') AND ObjectProperty(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[DNNLMapGetRIDToName2MigratedToUK]
GO


CREATE PROCEDURE dbo.DNNLMapGetRIDToName2MigratedToUK  
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
			ON nlv.RID = r.RID  and r.reststateid = 17
		INNER JOIN  Neighborhood n  
				ON  r.NeighborhoodID = n.NeighborhoodID  
  WHERE NLRuleID = 8 AND n.MetroAreaID= 72 AND  (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY nlv.RID  
)  
ORDER BY RID 

GO

GRANT EXECUTE ON [DNNLMapGetRIDToName2MigratedToUK] TO ExecuteOnlyRole
GO