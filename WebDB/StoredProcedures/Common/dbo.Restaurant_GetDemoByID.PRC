if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetDemoByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetDemoByID]
GO


CREATE PROCEDURE dbo.Restaurant_GetDemoByID
(@Restaurant_ID	int)

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

SELECT		r.RID as Restaurant_ID
			,r.RName as Name
			,Address1
			,Address2
			,City
			,State
			,Zip as Postal_Code
			,r.neighborhoodid as Neighborhood_ID
			,Phone
			,n.NBhoodName AS Neighborhood
			,n.metroareaid as Metro_Area_ID
			,ma.MetroAreaName AS Metro_Area_Name
			,rp.productDesc as Product_description

FROM		RestaurantVW r
INNER JOIN	NeighborhoodAVW n 
ON			r.neighborhoodid = n.neighborhoodid
and			n.LanguageID = r.LanguageID
INNER JOIN	MetroAreaAVW ma 
ON			n.metroareaid = ma.metroareaid
and			ma.LanguageID = r.LanguageID
INNER JOIN	Erbrestaurant er
ON			r.RID = er.RID
INNER JOIN	restaurantProduct rp
ON			er.productID = rp.productID

WHERE		r.RID = @Restaurant_ID


GO



GRANT EXECUTE ON [Restaurant_GetDemoByID] TO ExecuteOnlyRole

GO
