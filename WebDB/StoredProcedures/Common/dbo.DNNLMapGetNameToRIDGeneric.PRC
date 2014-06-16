IF EXISTS (SELECT * FROM dbo.SysObjects WHERE Id = Object_Id(N'[dbo].[DNNLMapGetNameToRIDGeneric]') AND ObjectProperty(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[DNNLMapGetNameToRIDGeneric]
GO

CREATE PROCEDURE [dbo].[DNNLMapGetNameToRIDGeneric]
(
  @MapFileGenDateTime datetime,
  @DomainId int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT NLMapValue + ' ' + NLMapKey
FROM dbo.NLURLVw 
WHERE NLDataID in 
(
      SELECT MAX(NLDataID) 
      FROM NLURLVw nlv
            INNER JOIN  Restaurant r
                        ON nlv.RID = r.RID
                  INNER JOIN  Neighborhood n
                              ON  r.NeighborhoodID = n.NeighborhoodID
      WHERE 
            NLRuleID = 1 
            AND 
            n.MetroAreaID IN (SELECT MetroAreaId FROM MetroArea WHERE DomainId = @DomainId)
            AND 
            DataLastModifiedDt  <= @MapFileGenDateTime
      GROUP BY nlv.RID
)
ORDER BY RID
GO

GRANT EXECUTE ON [DNNLMapGetNameToRIDGeneric] TO ExecuteOnlyRole
GO