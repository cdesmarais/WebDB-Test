if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserListFavorites]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserListFavorites]
GO


CREATE Procedure dbo.DNUserListFavorites
 (
  @UserID int,
  @IsCaller int = 0  --this param really just indicates if @UserID is a userid or a CallerID
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @IsCaller = 0
BEGIN
	SELECT 
				r.RName AS RestaurantName
				,ma.metroareaid as Metro_Area_ID
				,ma.MetroAreaName as Metroname
				,r.RID as Restaurant_ID
				,CASE 
				   WHEN (r.RestStateID = 1 AND r.IsReachable = 1)
				  	THEN r.IsReachable
				   ELSE cast(0 as bit)
				 END AS IsReachable
				,CASE WHEN (LEN(LTRIM(r.RSName)) = 0) THEN r.RName ELSE r.RSName END AS RSName
	from		RestaurantVW r
	INNER JOIN 	Neighborhood n 
	ON 			r.neighborhoodid = n.neighborhoodid
	INNER JOIN 	MetroAreaLocal ma
	ON 			n.metroareaid = ma.metroareaid
	and			ma.LanguageID = r.LanguageID
	INNER JOIN 	Favorites 
	ON 			r.RID = Favorites.RID
	Where		Favorites.CustID = @UserID 
	and			r.RestStateID in (1,5,6,7,16,13)
	ORDER BY	ma.MetroAreaName
				,r.RName

END
if @IsCaller > 0
BEGIN
	--Use Distinct; Concierges may have same restaurant in different folders
	SELECT distinct
				r.RName AS RestaurantName
				,ma.metroareaid as Metro_Area_ID
				,ma.MetroAreaName as Metroname
				,r.RID as Restaurant_ID
				,CASE 
				   WHEN (r.RestStateID = 1 AND r.IsReachable = 1)
				  	THEN r.IsReachable
				   ELSE cast(0 as bit)
				 END AS IsReachable
				,CASE WHEN (LEN(LTRIM(r.RSName)) = 0) THEN r.RName ELSE r.RSName END AS RSName
	from		RestaurantVW r
	INNER JOIN 	Neighborhood n 
	ON 			r.neighborhoodid = n.neighborhoodid
	INNER JOIN 	MetroAreaLocal ma
	ON 			n.metroareaid = ma.metroareaid
	and			ma.LanguageID = r.LanguageID
	INNER JOIN 	CallerRestaurants cr 
	ON 			r.RID = cr.RID
	Where		cr.CallerID = @UserID 
	and			r.RestStateID in (1,5,6,7,16,13)
	ORDER BY	ma.MetroAreaName
				,r.RName


END
GO

GRANT EXECUTE ON [DNUserListFavorites] TO ExecuteOnlyRole

GO
