if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllRestaurants]
GO

CREATE procedure [dbo].[Admin_CacheAllRestaurants] 
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

SELECT   
	r.rid AS restaurantid,  
	rname AS restaurantname,  
	rsname AS restaurantsname,  
	phone as restaurantphone,
	reststateid,  
	n.[metroareaid],   
	r.[LanguageID],  
	[MetroAreaName],  
	d.Domain,  
	d.DomainID,  
	Len(rname) as LenRName,
	d.[PrimaryLanguageID],
	n.[NeighborhoodID],
	r.Allotment,
	r.RestaurantType,
	r.City,
	r.BrandID,
	r.IsConnectFieldTest,
	(
		case 
			when r.RestaurantType = 'A'
				then 1
			when r.RestaurantType = 'G'
				then 	dbo.fIsGuestBridgeERBCCDisabled(erb.ERBversion)
			else  ---  'E'  ERB restaurants
				dbo.fIsPre80ERBAndCCDisabled(erb.ERBversion)
		end 
	) as ccDisabled
FROM		[restaurantavw] r  
INNER JOIN 	[NeighborhoodAVW] n  
ON 			r.[neighborhoodid] = n.[neighborhoodid]  
AND 		r.[LanguageID] = n.[LanguageID]  
INNER JOIN 	[MetroAreaAVW] m  
ON 			n.[MetroAreaID] = m.[MetroAreaID]  
AND 		n.[LanguageID] = m.[LanguageID]  
INNER JOIN 	Domain d  
ON 			r.domainid = d.[DomainID]
LEFT JOIN   ERBRestaurant  erb
ON 			erb.RID = r.RID

GO

GRANT EXECUTE ON [Admin_CacheAllRestaurants] TO ExecuteOnlyRole
GO