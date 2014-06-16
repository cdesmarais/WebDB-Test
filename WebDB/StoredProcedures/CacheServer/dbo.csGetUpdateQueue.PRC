--$ create proc csGetUpdateQueue
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csGetUpdateQueue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csGetUpdateQueue]
go
create procedure dbo.csGetUpdateQueue
(
  @CacheServerID int
)
as
	set nocount on
	set transaction isolation level read uncommitted

	-- If the Cache Server is running, purge all records for this 
    -- instance that were inserted before it started. Copied from 
	-- DNGetCSRestaurantUpdates
	declare @x int
	set @x = 1
	set rowcount 1000
	while @x > 0
	begin
		begin transaction
			  delete from CacheServerUpdateQueue
			  where TimestampUTC < ( select ActiveDT_UTC 
										   from CacheServer
										   where CacheServerID = @CacheServerID )
			  and CacheServerID = @CacheServerID
			  set @x = @@rowcount
		commit transaction
	end
	set rowcount 0

	select		
    -- Queue actions
		 q1.ID
		,q1.RID
		,q1.Action

	-- Restaurant info, must match dbo.csGetERBData and dbo.csGetActiveRests
		,er.StaticIPAddress				'StaticIP'
		,er.Track						'Track'
		,er.ServerIP					'IP'
		,er.RID							'RID'
		,UPPER(er.NetworkAddress)		'NetworkAddress'
		,UPPER(er.NewNetworkAddress)	'NewNetworkAddress'
		,er.ListenerVersion				'ListenerVersion'
		,r.RestStateID					'RestaurantStateID'
		,csg.CacheServerID				'CacheServerID'
		,csg.DestCacheServer			'DestCacheServer'
		,csg.DestWebServer				'DestWebServer'
		,er.ServerPwd					'AccessPwd'
		,er.IsInventory
	   ,ltc.LTC_UTC 'LTC'

	from		CacheServerUpdateQueue	q1

	-- This has the deficiency that the delete must always be inserted into the queue
	-- before the add. 
	left join	CacheServerUpdateQueue	q2
	on			q1.RID					 = q2.RID
	and			q2.ID					 < q1.ID
	and			q1.CacheServerID		!= q2.CacheServerID

	inner join  ERBRestaurant			er
	on			er.RID					= q1.RID

	inner join	Restaurant				r
	on			r.RID 				    = q1.RID

	left outer join LastTimeContacted	ltc
	on 			ltc.RID					= q1.RID

	left join	CacheServerERBGroup		csg
	on			csg.CacheServerERBGroupID   = er.CacheServerERBGroupID

	inner join	CacheServer				cs1
	on			cs1.CacheServerID		= q1.CacheServerID
	
	left outer join	CacheServer				cs2
	on			cs2.CacheServerID		= q2.CacheServerID

	where		q1.CacheServerID		= @CacheServerID
	and			
	( 
		(q2.ID is null)
		or 
		( 
			-- This clause ignores the delete entries when the
			-- cache server they belong to is down
			    (q2.ID is not null) 
			and (((cs2.CacheServerID is not null) 
				  and (cs2._IsUp = 0 ))
				 or  (q2.Action = 'I'))
		) 
	)
	
	AND		NOT(q1.Action = 'A' AND r.RestStateID = 16)
go
grant execute on dbo.csGetUpdateQueue to ExecuteOnlyRole
go
