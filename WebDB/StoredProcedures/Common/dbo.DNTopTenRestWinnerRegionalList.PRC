
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNTopTenRestWinnerRegionalList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNTopTenRestWinnerRegionalList]
go

create procedure dbo.DNTopTenRestWinnerRegionalList
as
set transaction isolation level read uncommitted

	--***************************************************************************************
	--** This stored proc returns the regional badges for the Diners' Choice Winners 		
	--** restaurant list.
	--** This info is used to on the Diners' Choice Winners page in OTRestaurant website.
	--** Content owned by India team, please notify asaxena@opentable.com if changing.
	--***************************************************************************************

	select 
		ttli.TopTenListInstanceID
		,ttlr.RID
		,coalesce(ttl.ListNameOverride, ttlt.ListName) TopTenListName
	from 
		TopTenListRestaurant ttlr		
	inner join 
		RestaurantVW r	
		on ttlr.RID = r.RID
		
	inner join
		NeighborhoodVW n
		on n.NeighborhoodID = r.NeighborhoodID
		
	inner join 
		MacroNeighborhoodVW mn
		on mn.MacroID = n.MacroID

	inner join 
		MetroAreaVW m
		on mn.MetroAreaID = m.MetroAreaID
		
	inner join
		TopTenListInstance ttli
		on ttli.TopTenListInstanceID = ttlr.TopTenListInstanceID

	inner join
		TopTenListVW ttl
		on ttl.TopTenListID = ttli.TopTenListID

	inner join
		TopTenListType ttlt
		on ttlt.TopTenListTypeID = ttl.TopTenListTypeID

	inner join
		TopTenImportJob ttij
		on ttij.TopTenImportJobID = ttli.TopTenImportJobID

	left join
		TopTenListRestaurantSuppression ttlrs
		on ttlrs.TopTenListID = ttl.TopTenListID	
		and ttlrs.RID = ttlr.RID

	where
		ttli.isActive = 1
		and coalesce(ttij.Status,1) = 1  
		and mn.Active = 1  
		and ttlrs.RID is null
		and ttlr.Rank <= 10
		and ttl.MacroID is not null 
		and ttl.TopTenListTypeID <> 22

	order by 
		ttlr.RID, TopTenListName

go

grant execute on [DNTopTenRestWinnerRegionalList] to ExecuteOnlyRole

go

