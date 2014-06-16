if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procUpdateIsReachable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procUpdateIsReachable]
GO

CREATE PROCEDURE dbo.procUpdateIsReachable
as

declare @curUTC as datetime, @curDT as Datetime
select @curUTC = GetUTCDate(), @curDT = GetDate()

-- the legacy mechanism for marking Umami restaurants uses a ValueLookupIDList-based whitelist; 
-- capture the lookup id
declare @UmamiValueLookupMaster int 
select @UmamiValueLookupMaster = LookupID from ValueLookupMaster where [Key] = 'UMAMI_RID_WHITELIST'

--*****************************
--** Enable restaurants that have recently come online
--*****************************
DECLARE @TempRest Table (rid int)

INSERT INTO @TempRest 
SELECT RID 
FROM	LastTimeContacted
WHERE LTC_UTC > DATEADD(mi,-8, @curUTC) ---This will do index seek 

update Restaurant    
set    IsReachable = 1 
from   Restaurant
inner  join @TempRest as er
on     Restaurant.RID = er.RID
where allotment = 0 and IsReachable <> 1


--*****************************
--** Force Allotment to always be in the same state based on the status in the ValueLookup table
--** Allotment does not have a LTC entry so it is entirely based on value lookup
--** Exclude Umami restaurants from this scheme
--*****************************
declare @AvailabilityDBStatus int
select	@AvailabilityDBStatus = ValueInt 
from	ValueLookup 
where	Ltype = 'DATABASE'
and	Lkey = 'AVAILABILITYDB_STATUS'

set @AvailabilityDBStatus = (case when @AvailabilityDBStatus = 1 then 1 else 0 end) /* Default to offline */
			
update		Restaurant    
set		IsReachable = @AvailabilityDBStatus 
from 		Restaurant r
left join	ValueLookupIDList v
on		(v.LookupID = @UmamiValueLookupMaster and v.ValueID = r.RID)
where		r.RestaurantType = 'A'
and		v.ValueID is null
and		r.IsReachable != @AvailabilityDBStatus

--*****************************
--** Force Umami restaurants to be reachable
--*****************************
update		Restaurant    
set		IsReachable = 1 
from 		Restaurant r
left join	ValueLookupIDList v
on		(v.LookupID = @UmamiValueLookupMaster and v.ValueID = r.RID)
where		IsReachable <> 1 and (RestaurantType = 'C' or (RestaurantType = 'A' and v.ValueID is not null))



--*****************************
--** Disable restauratns that have recently gone offline
--**
--*****************************

--***************
--** Set Restaurants to Unreachable
--** Clear FRN if necessary
--***************
update      Restaurant      -- with (UPDLOCK)
set         IsReachable         = 0, 
	    RestStateID         = (case when RestStateID = 16 then 1 else RestStateID end)
from        Restaurant          r  
                
inner join  LastTimeContacted   ltc
on          ltc.RID             = r.RID

inner join  ERBRestaurant       erb
on          erb.RID             = r.RID

left join   CacheServerERBGroup csg
on          csg.CacheServerERBGroupID = erb.CacheServerERBGroupID

left join   CacheServer         cs
on          cs.CacheServerID    = csg.CacheServerID

where       -- this is a heartbeating restaurant (ERB or GERB)
            RestaurantType in ('E', 'G')
            
            -- the managing Cache Server did not go down in the last 15 minutes,
			-- (or there is no managing Cache Server instance)
and         not (datediff(mi, coalesce(cs.DownDT_UTC, '01/01/1990'), @curUTC) < 15)

            -- the ERB LTC is older than 15 minutes
and			ltc.LTC_UTC < DATEADD(mi,-15, @curUTC)
            -- the ERB is currently flagged as being reachable
and         r.IsReachable       = 1

-- Should we track rest state transition here? Its hard in this case because its a bulk update, we would need 
-- to find out which restaurants fit the update criteria and then update those restaurants, but due to the time delta
-- its possible to lose out on some restaurants! 


GO

GRANT EXECUTE ON [procUpdateIsReachable] TO ExecuteOnlyRole

GO