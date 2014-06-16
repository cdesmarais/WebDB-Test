if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantFoodTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantFoodTypes]
GO



/*
This proc is used by OT_MgrCache/StoredProcTab.cs in ConsumerSite to fetch data for WebCache
*/

CREATE Procedure dbo.DNCacheRestaurantFoodTypes

AS

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT		fts.RID
			,fts.FTRank
			,ft.FoodType AS FoodTypeName
FROM			FoodTypes fts
INNER JOIN		FoodType ft
ON			fts.FoodTypeID = ft.FoodTypeID
INNER JOIN		RestaurantVW r
on			r.RID=fts.rid
and			r.languageid=ft.languageid
and				r.RestStateID != 4 --** Do not include inactive restaurnts
GO




GRANT EXECUTE ON [dbo].[DNCacheRestaurantFoodTypes] TO ExecuteOnlyRole

GO
