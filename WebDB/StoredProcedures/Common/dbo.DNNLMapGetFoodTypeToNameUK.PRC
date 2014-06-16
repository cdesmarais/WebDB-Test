if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNLMapGetFoodTypeToNameUK]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNLMapGetFoodTypeToNameUK]
GO

CREATE PROCEDURE dbo.DNNLMapGetFoodTypeToNameUK
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
  WHERE NLRuleID =7 AND MetroAreaID=72 AND (DataLastModifiedDt  <= @MapFileGenDateTime)
  GROUP BY MetroAreaID,FoodTypeID
)
ORDER BY	MetroAreaID,FoodTypeID
GO

GRANT EXECUTE ON [DNNLMapGetFoodTypeToNameUK] TO ExecuteOnlyRole
GO