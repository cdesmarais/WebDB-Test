
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GMAP_GetRegions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GMAP_GetRegions]
GO




CREATE PROCEDURE dbo.GMAP_GetRegions

AS

Select '<location id="' + cast(mn.MacroID as nvarchar(5)) + 
'" infoStyle="http://mygmaps.com/style/minipage.xsl"><point lat="' + 
cast(avg(Latitude) as nvarchar(15)) + '" lng="' + cast(avg(Longitude) as nvarchar(15)) +
'"/><icon class="local" image="http://maps.google.com/mapfiles/marker.png"/><info><minipage><div><h3>' + 
replace(replace(replace(replace(replace(replace(replace(replace(MacroName,'&','and'),'é','e'),'ó','o'),'¡','!'),'ë','e'),'á','a'),'ô','o'),'è','e') + '</h3><reference>' + 
'<url><a href="http://mygmaps.com/show/0.0.6/?url=http://otcon1.opentable.com/xml/restaurants.asp?id=' + 
cast(mn.MacroID as nvarchar(5)) + '">see all ' + cast(count(r.rid) as nvarchar(4)) + ' restaurants</a></url>' + 
--Case when(restaurantImage.rid is not null) then '<img src="http://www.opentable.com/img/restimages/' + 
--cast(r.RID as nvarchar(5)) + '.jpg" />' else '' end + 
'</reference><title xml:space="preserve">sub-header</title></div></minipage></info></location>' as XMLValue, avg(Latitude) as Latitude, avg(Longitude) as Longitude
from		restaurantVW r
inner join	neighborhoodAVW n
on			r.neighborhoodID = n.neighborhoodID
and			r.LanguageID = n.LanguageID
inner join MacroneighborhoodAVW mn
on			n.MacroID = mn.MacroID
and			r.LanguageId = mn.LanguageID
--left outer join restaurantImage on r.rid = restaurantImage.RID
 where reststateID != 4 and n.MetroareaID != 1 and Latitude is not null and Longitude is not null
and r.rid not in (400,2951)
group by MacroName, mn.MacroID

GO


GRANT EXECUTE ON [GMAP_GetRegions] TO ExecuteOnlyRole

GO
