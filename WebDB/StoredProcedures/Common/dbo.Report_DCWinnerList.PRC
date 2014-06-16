if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_DCWinnerList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_DCWinnerList]
GO

CREATE PROCEDURE [dbo].[Report_DCWinnerList]

AS

select  
	m.MetroAreaID, 
	m.MetroAreaName as [MetroAreaName],
	coalesce( ttl.listnameoverride, ttlt.listname ) as [ListName],
	ttlr.RID,
	r.RName as RestaurantName,
	ttlr.Rank as [Rank],
	r.Address1 as RestaurantAddress1,
	r.Address2 as RestaurantAddress2,
	r.City,
	r.State,
	r.Zip,
	case when (ttl.MacroID IS NULL OR ttl.TopTenListTypeID = 22) then 'No' ELSE 'Yes' END as IsRegionalList,
	case when (ttl.MacroID IS NULL OR ttl.TopTenListTypeID = 22) then '' Else mn.MacroName END as [MacroName],
	'http://' + d.PublicSite +'/rest_profile.aspx?rid=' + Cast(r.RID as nvarchar(10))+'&restref=' + Cast(r.RID as nvarchar(10))+ '&cmpid=dcw' as RIDURL
	,ISNULL(g.GroupName,'') as RestaurantGroup 
from TopTenListRestaurant ttlr	 
inner join RestaurantVW r  
	on   ttlr.RID      = r.RID  
inner join NeighborhoodVW     n  
	on   n.NeighborhoodID    = r.NeighborhoodID  
inner join MacroNeighborhoodVW    mn  
	on   mn.MacroID      = n.MacroID
inner join MetroAreaVW m
	on m.MetroAreaID = n.MetroAreaID 
inner join Domain d 
	on m.SupportedDomainID = d.DomainID   
inner join TopTenListInstance ttli 
	on ttli.TopTenListInstanceID = ttlr.TopTenListInstanceID
inner join TopTenList ttl
	on ttl.TopTenListID = ttli.TopTenListID
inner join TopTenListType ttlt
	on ttlt.TopTenListTypeID = ttl.TopTenListTypeID
inner join TopTenImportJob     ttij  
	on ttij.TopTenImportJobID = ttli.TopTenImportJobID  
left join TopTenListRestaurantSuppression ttlrs  
	on ttlrs.TopTenListID = ttl.TopTenListID
	and ttlrs.RID = ttlr.RID  
left join RestaurantToGroup rg 
 	on r.RID = rg.RID
left join RestaurantGroup g
 	on rg.GID = g.GID        
where ttli.isActive = 1
	and coalesce(ttij.Status,1) = 1  
	and mn.Active = 1  
	and ttlrs.RID is null
	and ttlr.Rank <= 10
	and M.metroAreaID <> 1 --exclude demoland.  
order by	[MetroAreaName],
			[MacroName],
			[ListName],
			[Rank]

Go

GRANT  EXECUTE  ON [Report_DCWinnerList]  TO [ExecuteOnlyRole]

Go
