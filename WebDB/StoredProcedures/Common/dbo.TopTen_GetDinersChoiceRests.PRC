if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_GetDinersChoiceRests]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_GetDinersChoiceRests]
GO

CREATE Procedure dbo.TopTen_GetDinersChoiceRests
AS

select  
	ListPosition = 1, --a placeholder for use by Charm to insert the real data
	ttlr.Rank as [Position],
	CAST(ttli.TopTenListInstanceID as nvarchar(15)) + CAST(ttlr.RID as nvarchar(15)) as UniqueID , 
    ttlt.TopTenListTypeID as ListID,
	dbo.fn_HtmlEncode(coalesce( ttl.listnameoverride, ttlt.listname ),0) as [ListTopic],
	ListTopicUrl = 'xx', --a placeholder for use by Charm to insert the real data
	m.MetroAreaID, 
	dbo.fn_HtmlEncode(m.MetroAreaName,0) as [MetroAreaName],
	dbo.fn_HtmlEncode(mn.MacroName,0) as [Region],
	dbo.fn_HtmlEncode(RName,0) as RestaurantName,
	dbo.fn_HtmlEncode(pq.Symbols,0) as Price,
	dbo.fn_HtmlEncode(n.NbhoodName,0) as NeighborhoodName,
	dbo.fn_HtmlEncode(ft.FoodType,0) as PrimaryFoodType,
	dbo.fn_HtmlEncode(Address1,0) as RestaurantAddress1,
	dbo.fn_HtmlEncode(Address2,0) as RestaurantAddress2,
	dbo.fn_HtmlEncode(City,0) as City,
	dbo.fn_HtmlEncode(State, 0) as State,
	Zip as PostalCode,
	ttlr.RID,
	left(cast(r.rid as varchar(20)),1) as RestID_1st,
	dbo.fn_HtmlEncode(rst.RState,0) as CharmStatus,
	ttli.TopTenListInstanceID,
	ttli.TopTenListID
from TopTenListRestaurant ttlr	 
inner join RestaurantVW r  
	on   ttlr.RID      = r.RID  
inner join NeighborhoodVW     n  
	on   n.NeighborhoodID    = r.NeighborhoodID  
inner join MacroNeighborhoodVW    mn  
	on   mn.MacroID      = n.MacroID
inner join MetroAreaVW m
	on m.MetroAreaID = n.MetroAreaID 
inner join TopTenListInstance ttli 
	on ttli.TopTenListInstanceID = ttlr.TopTenListInstanceID
inner join TopTenList ttl
	on ttl.TopTenListID = ttli.TopTenListID
inner join TopTenListType ttlt
	on ttlt.TopTenListTypeID = ttl.TopTenListTypeID
inner join TopTenImportJob     ttij  
	on ttij.TopTenImportJobID = ttli.TopTenImportJobID  
INNER JOIN dbo.FoodTypes AS fts 
	ON r.RID = fts.RID AND fts.IsPrimary = 1 
INNER JOIN dbo.FoodType AS ft 
	ON fts.FoodTypeID = ft.FoodTypeID 
		AND ft.LanguageID = r.LanguageID 
INNER JOIN dbo.PriceQuartileAVW AS pq 
	ON pq.PriceQuartileID = r.PriceQuartileID 
		AND pq.LanguageID = r.LanguageID 
		AND pq.CountryID = r.Country
inner join dbo.RestaurantState rst
	on rst.RestStateID = r.RestStateID
left join TopTenListRestaurantSuppression ttlrs  
	on ttlrs.TopTenListID = ttl.TopTenListID
	and ttlrs.RID = ttlr.RID  
 	
where ttli.isActive = 1
	and coalesce(ttij.Status,1) = 1  
	and mn.Active = 1  
	and ttlrs.RID is null
	and ttlr.Rank <= 10
	and M.metroAreaID <> 1 --exclude demoland.  
	and (ttl.MacroID IS NULL AND ttl.TopTenListTypeID <> 22) --don't want regional lists
	and m.MetroAreaID = ttl.MetroAreaID --exclude duplicates (rank, metro, list name) with different instance ids
	
order by	[MetroAreaName],
			[ListName],
			ttlr.Rank,
			[MacroName]

go

GRANT  EXECUTE  ON [TopTen_GetDinersChoiceRests]  TO [ExecuteOnlyRole]

Go
