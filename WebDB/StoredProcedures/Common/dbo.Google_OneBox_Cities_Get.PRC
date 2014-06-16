if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Google_OneBox_Cities_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Google_OneBox_Cities_Get]
GO

CREATE PROCEDURE dbo.Google_OneBox_Cities_Get

AS
Set nocount on
Set transaction isolation level read uncommitted

Select 
dbo.fNLURLEncode('<DataObject id="City' + cast(max(r.RID) as varchar(5)) + '" type="OTCity">' + 
'<QueryName value="' + 
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(City,'&','and'),'=','o'),'í','!'),'ß','a'),'(','o'),'á','a'),'ç','c'),'é','e'),'è','e'),'ë','e'),'ñ','n'),'ó','o'),'ô','o'),'¡','!'),'²','2'),'•',' '),'”',''),'“',''),' ','')
	+ State + '"/>' + 
'<Attribute name="fullname" value="' + 
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(City,'&','and'),'=','o'),'í','!'),'ß','a'),'(','o'),'á','a'),'ç','c'),'é','e'),'è','e'),'ë','e'),'ñ','n'),'ó','o'),'ô','o'),'¡','!'),'²','2'),'•',' '),'”',''),'“','')
	 + '"/>' + 
'<Attribute name="metroname" value="' + replace(m.MetroAreaName,'&','&amp;') + '"/>' + 
'<Attribute name="metroid" value="' + cast(m.MetroAreaID as varchar(5)) + '"/>' + 
'</DataObject>') as xmldata
from RestaurantVW r
inner join NeighborhoodVW n on r.neighborhoodID = n.neighborhoodID
inner join MetroareaVW m on n.MetroareaID = m.MetroareaID
where r.reststateID in (1,5,6,7,16,13) and m.Active = 1 and rid != 6332 and m.MetroAreaID != 58
and r.City is not null
group by r.City, m.MetroareaName, m.MetroAreaID, r.State

GO

GRANT EXECUTE ON [Google_OneBox_Cities_Get] TO ExecuteOnlyRole

GO

