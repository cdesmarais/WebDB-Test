if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetNameToFoodTypeUK]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetNameToFoodTypeUK]
GO

CREATE PROCEDURE dbo.DNNLMapGetNameToFoodTypeUK
(
  @MapFileGenDateTime datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	NLMapValue + ' ' + NLMapKey
FROM		dbo.NLURLVw
WHERE 		NLDataID  in 
( SELECT MAX(NLDataID) FROM NLURLVw
  WHERE NLRuleID =7 AND MetroAreaID=72 AND (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY FoodTypeID
)
ORDER BY FoodTypeID
GO

GRANT EXECUTE ON [DNNLMapGetNameToFoodTypeUK] TO ExecuteOnlyRole
GO