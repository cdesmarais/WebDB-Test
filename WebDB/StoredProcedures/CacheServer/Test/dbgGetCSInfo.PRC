--$ create proc dbgGetCSInfo
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dbgGetCSInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[dbgGetCSInfo]
go
create proc dbo.dbgGetCSInfo
as
	select		 cs.CacheServerID	
				,csg.CacheServerERBGroupID	'GroupID'
				,s.IPAddress
				,cs.InternalDNS		
				,csg.DestCacheServer
				,csg.DestWebServer
				,cs.ActiveDT_UTC		'LastUpdated'
				,cs._IsUp				'IsUp'
				,s.Active	
				,ss.VersionNumberLive	'Version'
				,ss.StaticChecksumLive	'Checksum'

	from		CacheServer 		cs

	left join	ServerSite 			ss
	on			ss.ServerID 		= cs.ServerID

	left join 	Server				s
	on			cs.ServerID			= s.ServerID

	left join 	CacheServerERBGroup	csg
	on			csg.CacheServerID 	= cs.CacheServerID
go
