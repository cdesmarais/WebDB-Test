if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheRestaurantSearchList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheRestaurantSearchList]
go

--*********************************************************
--** Retrieves essential restaurant data (rid, IP, search rules)
--** needed to support the availability service
--*********************************************************

create procedure dbo.ObjectCacheRestaurantSearchList
as

	set transaction isolation level read uncommitted
	set nocount on
		
	declare @ERBSearchBlacklistMasterID int = 66
	declare @UmamiWhitelistMasterID int = 90

	select		 
				r.RID,
				r.RestaurantType,
				[IsWhitelistedForUmami] = case when (coalesce(v1.ValueID, 0) = 0) then convert(bit,0) else convert(bit,1) end,
				n.MetroAreaID as metroareaid,
				r.RestStateID,
				r.IsReachable
				,[ERBIPAddress] =  (case when (charindex(':',er.serverIP) > 0)
					then substring(serverIP, 1, charindex(':',er.serverIP)-1) 
					else ''
					end) 
					 
				,[ERBPort] = (case when (charindex(':',er.serverIP) > 0)
					then cast(substring(serverIP, charindex(':',er.serverIP)+1, 10) as int)
					else -1
					end)
				,[ERBPassword] = er.serverPwd
				,[ERBVersion] = er.ListenerVersion
				,[IsTracked] = er.Track
				,[ERBSearchIsBlacklisted] = case when (coalesce(v2.ValueID, 0) = 0) then convert(bit,0) else convert(bit,1) end
				,[OTAvailabilityInstanceID] =
					CASE
						WHEN r.IsConnectFieldTest = 1 THEN 2		 -- OTAInstanceID, per the config file, associated with OTAvailability_FT
						WHEN r.RestaurantType = 'A' THEN 1			 -- OTDOTAInstnceID, per the config file,  for OTAvailability
						ELSE NULL								 -- Not a Connect RID
					 END
				
				,[MinPartySize] = r.MinOnlineOptionID	
				,[MaxPartySize] = coalesce(r.MaxLargePartyID, 10000)	
				,[MaxDaysInAdvance] = Cast(mao.Days as int) 	
				,[EarlyCutoff] = case when (coalesce(rss.SuppressionDays, 0) < 1) then convert(bit,0) else convert(bit,1) end  --Search Early Cut Off
				,[EarlyCutoffDays] = coalesce(rss.SuppressionDays, 0) -- Number of days for Search Early Cut Off
				,[HasCreditCardPartySizeThreshold] = r.AcceptLargeParty
				,[CreditCardPartySizeThreshold] = mxo.MaxValue
				,[HasEMH] = CASE WHEN (csg_emh.CacheServerERBGroupID IS NULL) then convert(bit,0) else convert(bit,1) end
				,[TimeZoneOffset] = coalesce(t.ServerToLocalOffset, 0)

	from		dbo.Restaurant r
	inner join	dbo.Neighborhood n 
	on			n.neighborhoodid = r.neighborhoodid
	inner join	dbo.ERBRestaurant er
	on			r.RID = er.RID
	inner join	dbo.MaxAdvanceOption mao
	on			r.MaxAdvanceOptionID = mao.MaxAdvanceOptionID
	inner join	dbo.MaxOnlineOption mxo
	on			r.MinCCOptionID = mxo.MaxOnlineOptionID
	INNER JOIN	TimeZoneVW t 
	ON			r.TZID = t.TZID 
	
	left join	dbo.RestaurantSuppression rss
	on			(r.RID = rss.RID and rss.RestaurantSuppressionTypeId = 4)  -- Search Early Cutoff type 
	-- Umami whitelist
	left join	dbo.ValuelookupIDList v1
	on			(r.RID = v1.ValueID and v1.LookupID = @UmamiWhitelistMasterID)
	--ERB Search Blacklist
	left join	dbo.ValuelookupIDList v2
	on			(r.RID = v2.ValueID and v2.LookupID = @ERBSearchBlacklistMasterID)
	--Is there an EMH
	left JOIN	CacheServerErbGroup	csg_emh
	on			(csg_emh.CacheServerERBGroupID = er.CacheServerERBGroupID and csg_emh.GroupName	LIKE '%EMH')

	where		r.RestStateID != 4
go

grant execute on [ObjectCacheRestaurantSearchList] TO ExecuteOnlyRole
go
