if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Google_OneBox_Restaurants_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Google_OneBox_Restaurants_Get]
GO

CREATE PROCEDURE dbo.Google_OneBox_Restaurants_Get

AS
Set nocount on
Set transaction isolation level read uncommitted



Select dbo.fNLURLEncode(
'<DataObject id="Restaurant' + cast(r.RID as varchar(5)) + '" type="Restaurant">' + 
'<QueryName value="' + 
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(rname,'&','and'),'=','o'),'í','!'),'ß','a'),'(','o'),'á','a'),'ç','c'),'é','e'),'è','e'),'ë','e'),'ñ','n'),'ó','o'),'ô','o'),'¡','!'),'²','2'),'•',' '),'”',''),'“','')
	 + '"/>' + 
(case When (charindex('''',rname) > 0) THEN 
'<QueryName value="' + 
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(rname,'&','and'),'=','o'),'í','!'),'ß','a'),'(','o'),'á','a'),'ç','c'),'é','e'),'è','e'),'ë','e'),'ñ','n'),'ó','o'),'ô','o'),'¡','!'),'²','2'),'•',' '),'”',''),'“',''),'''','')
	 + '"/>' ELSE '' END)
+
(case When (charindex('-',rname) > 3) THEN 
'<QueryName value="' + 
left(
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(rname,'&','and'),'=','o'),'í','!'),'ß','a'),'(','o'),'á','a'),'ç','c'),'é','e'),'è','e'),'ë','e'),'ñ','n'),'ó','o'),'ô','o'),'¡','!'),'²','2'),'•',' '),'”',''),'“',''),'''','')
	,charindex('-',rname)-2) + '"/>' ELSE '' END)
+ 
(case When (charindex('(',rname) > 3) THEN 
'<QueryName value="' + 
left(
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(rname,'&','and'),'=','o'),'í','!'),'ß','a'),'(','o'),'á','a'),'ç','c'),'é','e'),'è','e'),'ë','e'),'ñ','n'),'ó','o'),'ô','o'),'¡','!'),'²','2'),'•',' '),'”',''),'“',''),'''','')
	,charindex('(',rname)-1) + '"/>' ELSE '' END)
+ 
(case When (charindex(' ',replace(rname,'The ',''),charindex(' ',replace(rname,'The ',''))+1) > 3) THEN 
'<QueryName value="' + 
left(
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(rname,'&','and'),'=','o'),'í','!'),'ß','a'),'(','o'),'á','a'),'ç','c'),'é','e'),'è','e'),'ë','e'),'ñ','n'),'ó','o'),'ô','o'),'¡','!'),'²','2'),'•',' '),'”',''),'“',''),'''',''),'The ','')
	,charindex(' ',replace(rname,'The ',''),charindex(' ',replace(rname,'The ',''))+1)-1) + '"/>' ELSE '' END)
+ 
(case When (charindex('The ',rname) = 1) THEN 
'<QueryName value="' + 
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(rname,'&','and'),'=','o'),'í','!'),'ß','a'),'(','o'),'á','a'),'ç','c'),'é','e'),'è','e'),'ë','e'),'ñ','n'),'ó','o'),'ô','o'),'¡','!'),'²','2'),'•',' '),'”',''),'“',''),'''',''),'The ','')
	 + '"/>' ELSE '' END)
+ 
(case When (charindex(' the ',rname) > 3) THEN 
'<QueryName value="' + 
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(rname,'&','and'),'=','o'),'í','!'),'ß','a'),'(','o'),'á','a'),'ç','c'),'é','e'),'è','e'),'ë','e'),'ñ','n'),'ó','o'),'ô','o'),'¡','!'),'²','2'),'•',' '),'”',''),'“',''),'''',''),' the ',' ')
	 + '"/>' ELSE '' END)
+ 
'<Attribute name="fullname" value="' + 
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(rname,'&','and'),'=','o'),'í','!'),'ß','a'),'(','o'),'á','a'),'ç','c'),'é','e'),'è','e'),'ë','e'),'ñ','n'),'ó','o'),'ô','o'),'¡','!'),'²','2'),'•',' '),'”',''),'“','')
	 + '"/>' + 
'<Attribute name="rid" value="' + cast(r.RID as varchar(5)) + '"/>' + 
'<Attribute name="metroname" value="' + replace(m.MetroAreaName,'&','&amp;')  + '"/>' + 
'<Attribute name="metroid" value="' + cast(m.MetroAreaID as varchar(5)) + '"/>' + 
'</DataObject>') as xmldata
from RestaurantVW r
inner join NeighborhoodVW n on r.neighborhoodID = n.neighborhoodID
inner join MetroareaVW m on n.MetroareaID = m.MetroareaID
where r.reststateID in (1,5,6,7,16,13) and m.Active = 1 and m.MetroAreaID != 58
and r.rname is not null

GO

GRANT EXECUTE ON [Google_OneBox_Restaurants_Get] TO ExecuteOnlyRole

GO
