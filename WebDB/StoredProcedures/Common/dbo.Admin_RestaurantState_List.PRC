if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_RestaurantState_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_RestaurantState_List]
GO

CREATE PROCEDURE dbo.Admin_RestaurantState_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 	RestStateID AS RestaurantStateID,
		RState as Name, 
		AppliesToAllotment
FROM 	RestaurantState 
WHERE 	(RestStateID != 9  AND RestStateID != 17)
GO

GRANT EXECUTE ON [Admin_RestaurantState_List] TO ExecuteOnlyRole
GO

