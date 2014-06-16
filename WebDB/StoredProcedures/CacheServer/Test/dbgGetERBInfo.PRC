--$ create proc dbgGetERBInfo
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dbgGetERBInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[dbgGetERBInfo]
go
create proc dbo.dbgGetERBInfo
(
	 @RIDbegin int
	,@RIDEnd int = null
)	
as

/*
select top 100 * from erbrestaurant
select top 100 * from restaurant
select top 100 * from cacheservergroup
select top 100 * from cacheserver
select top 100 * from server
select top 100 * from serversite
*/

if @RIDEnd is null
begin
	set @RIDEnd = @RIDbegin
end

select		 er.RID
			,rs.RState				'State'
			,convert(char(19), ltc.LTC, 20)				'LTC'
			,er.ServerIP			'ERBIP'
			,er.ServerPwd			'AccessPwd'
			,er.ERBVersion
			,er.NetworkAddress
			,er.Track
			,er.IsInventory			'Inventory'
			,csg.DestCacheServer	'CS'
			,s.IPAddress			'CSIP'
			,cs._IsUp				'CSIsUp'
			,csg.DestWebServer		'WWW'		
			
from		ERBRestaurant			er

inner join	Restaurant				r
on			r.RID =	er.RID

inner join	RestaurantState			rs
on			rs.RestStateID = r.RestStateID

left outer join	CacheServerERBGroup		csg
on			csg.CacheServerERBGroupID = er.CacheServerERBGroupID

left outer join	CacheServer				cs
on			cs.CacheServerID = csg.CacheServerID

left outer join	Server					s
on			s.ServerID = cs.ServerID

inner join	LastTimeContacted		ltc
on			ltc.RID = er.RID

where		er.RID between @RIDBegin and @RIDEnd
	
go
