if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetNameToFoodType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetNameToFoodType]
GO

CREATE PROCEDURE dbo.DNNLMapGetNameToFoodType
(
  @MapFileGenDateTime datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	NLMapValue + ' ' + NLMapKey
FROM		dbo.NLURLVw
WHERE 		NLDataID  in 
(SELECT MAX(NLDataID) FROM NLURLVw
  WHERE NLRuleID =7 AND (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY MetroAreaID,FoodTypeID
)
ORDER BY	MetroAreaID,FoodTypeID
GO

GRANT EXECUTE ON [DNNLMapGetNameToFoodType] TO ExecuteOnlyRole
GO