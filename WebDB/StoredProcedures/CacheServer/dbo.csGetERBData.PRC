--$ create proc csGetERBData
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csGetERBData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csGetERBData]
GO

create  procedure dbo.csGetERBData
(
	@nRestaurantID int
)
as
    set transaction isolation level read uncommitted
    set nocount on
    
    -- This must match the columns returned by dbo.csGetActiveRests
    select		distinct
			     er.StaticIPAddress				'StaticIP'
			    ,er.Track						'Track'
			    ,er.ServerIP					'IP'
			    ,er.RID							'RID'
			    ,UPPER(er.NetworkAddress)		'NetworkAddress'
			    ,UPPER(er.NewNetworkAddress)	'NewNetworkAddress'
			    ,er.ListenerVersion			'ListenerVersion'
			    ,r.RestStateID			'RestaurantStateID'
			    ,csg.CacheServerID			'CacheServerID'
		            ,csg.DestCacheServer		'DestCacheServer'
			    ,csg.DestWebServer			'DestWebServer'
				,er.ServerPwd			'AccessPwd'
				,er.IsInventory
				,ltc.LTC_UTC 'LTC'
    
    from		ERBRestaurant er
    inner join	Restaurant r
    on			r.RID = er.RID

	left outer join	LastTimeContacted ltc
	on			ltc.RID = er.RID

    inner join	CacheServerERBGroup csg
    on		er.CacheServerERBGroupID = csg.CacheServerERBGroupID

    where		er.RID = @nRestaurantID

go
GRANT EXECUTE ON [csGetERBData] TO ExecuteOnlyRole
GO
