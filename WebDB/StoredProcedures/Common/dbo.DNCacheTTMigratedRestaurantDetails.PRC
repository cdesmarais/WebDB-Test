if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheTTMigratedRestaurantDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[DNCacheTTMigratedRestaurantDetails]
GO

create Procedure [dbo].[DNCacheTTMigratedRestaurantDetails]
as

	set transaction isolation level read uncommitted
	set nocount on

	select 
			r.RID as RestaurantID,
			rl.RName as RestaurantName,
			case 
			   when (r.RestStateID = 1 and r.IsReachable = 1)then 1 
			   else 0 
			end as IsAvailable,
			r.IsReachable as HasHeartbeat,
			r.Allotment,
			n.MetroAreaID as Metro_Area_ID,
			r.RestaurantType
	from dbo.Restaurant r
	inner join dbo.RestaurantLocal rl 
		on rl.rid = r.rid
	inner join dbo.Domain d 
		on d.domainID = r.DomainID
	inner join dbo.DBUser db 
		on r.DomainID = IsNull(db.domainID, r.DomainID) -- Always match when No Domain Supplied
		and rl.LanguageID = IsNull(db.LanguageID, PrimaryLanguageID) -- If no language specified the primary language
	inner join NeighborhoodVW n 
		on n.NeighborhoodID = r.NeighborhoodID
		
	left join  valuelookup ForceMigrate -- Special Case to force all UK IE rids to be treated as migrated
		on	LType = 'DATABASE'          -- This left join can be removed after UK migration
		and	LKey = 'ForceMigrateRIDs'
	
	where (r.RestStateID = 17  -- TopTable Migrated Restaurants
			or		(r.country in ('UK', 'IE')	and		IsNull(ForceMigrate.ValueInt,0) = 1)  -- This or clause can be removed after UK migration
	)
	and db.dbuser = User


go


grant execute on [DNCacheTTMigratedRestaurantDetails] TO ExecuteOnlyRole

GO
