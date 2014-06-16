if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetFoodTypeToName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetFoodTypeToName]
GO

CREATE PROCEDURE dbo.DNNLMapGetFoodTypeToName
(
  @MapFileGenDateTime datetime
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		NLMapKey + ' ' + NLMapValue 
FROM		dbo.NLURLVw
WHERE 		NLDataID  in 
(SELECT MAX(NLDataID) FROM NLURLVw
  WHERE NLRuleID =7 AND (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY MetroAreaID,FoodTypeID
)
ORDER BY	MetroAreaID,FoodTypeID
GO

GRANT EXECUTE ON [DNNLMapGetFoodTypeToName] TO ExecuteOnlyRole
GO