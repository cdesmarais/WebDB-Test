	GO

	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GMAP_GetTest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[GMAP_GetTest]
	GO







	CREATE PROCEDURE dbo.GMAP_GetTest

	AS


	Select '<h3>' + 
	replace(replace(replace(replace(replace(replace(replace(replace(MacroName,'&','and'),'T','e'),'=','o'),'í','!'),'d','e'),'ß','a'),'(','o'),'F','e') + '</h3><br><br>' + 
	'<a href=gmaprestaurants.asp?id=' + 
	cast(mn.MacroID as nvarchar(5)) + '>see all ' + cast(count(r.rid) as nvarchar(4)) + ' restaurants</a>'
	as htmlText, avg(Latitude) as Latitude, avg(Longitude) as Longitude
	from		restaurantVW r
	inner join	neighborhoodAVW n
	on			r.neighborhoodID = n.neighborhoodID
	and			r.LanguageID = n.LanguageID
	inner join MacroneighborhoodAVW mn
	on			n.MacroID = mn.MacroID
	and			r.LanguageId = mn.LanguageID
	--left outer join restaurantImage on r.rid = restaurantImage.RID	
	 where reststateID = 1 and n.MetroareaID != 1 and Latitude is not null and Longitude is not null
	and r.rid not in (400,2951)
	group by MacroName, mn.MacroID


	GO

	GRANT EXECUTE ON [GMAP_GetTest] TO ExecuteOnlyRole

	GO
