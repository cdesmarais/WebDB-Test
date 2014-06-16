if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procGetDCListsForReportFeed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procGetDCListsForReportFeed]
GO

CREATE Procedure dbo.procGetDCListsForReportFeed
As

set transaction isolation level read uncommitted
set nocount on

/*
This proc will give top three DC metro lists for restaurant sorted by TopTenListType display order (ToptenListTypeClass::DisplayOrder).
This proc will be called as part of DNGenGoogleFeed procedure thats used for generating Google feed reviews.
*/


--Limit three lists for each restaurant. 
--Not sure if this value needs to be configured.
Declare @DCRowsLimit int = 3;

/*
DC Cuisine List - Name Override
'Dessert','Fondue','Gastro Pub','Seafood',Steak','Sushi','Tapas / Small Plates'
All the Cuisines will be pulled in from webDB for specific user's language ID 
Source: Josh's PDF document on renamed CuisineLists
construct a list of foodtypes that will not be renamed using standard template Ex:"Best Italian Food"
Google feed is generated using WebUser Login, which is tied to LanguageID = 1.
Also the FoodTypeIDs listed in where clause are all tied to LanguageID=1.
We will use same here for query to make it DB I18n compliant.
 */
select	FoodTypeID,
		FoodType
into	#TempCuisineDCNameChangeExclude
from	FoodType f
where FoodTypeID in (19,24,25,53,78,82,96)
and LanguageID = 1 

--Get DC metro topten lists
select 	row_number() over(PARTITION BY ttlr.RID ORDER BY ttlc.DisplayOrder desc) as DCRowRank,    
		ttlr.RID,
		ttl.TopTenListID,
		ttl.MetroAreaID,
		ttl.MacroID,
		ttl.TopTenListTypeID,
		mv.ShowRegionLists,
		coalesce( ttl.listnameoverride, ttlt.listname ) as OriginalListName,
		CASE WHEN (ttl.CuisineID IS NOT NULL AND tce.FoodTypeID IS NULL) THEN --ex:Best American Food
				'Best ' + coalesce( ttl.listnameoverride, ttlt.listname ) + ' Food'
			 WHEN (tce.FoodTypeID IS NOT NULL) THEN --ex:Best Steak
				'Best ' + coalesce( ttl.listnameoverride, ttlt.listname )
			Else coalesce( ttl.listnameoverride, ttlt.listname )
		END as [ListName]  
into #TempTopTenWithRowNumbers
from TopTenListRestaurant ttlr    
inner join TopTenListInstance ttli   
 on ttli.TopTenListInstanceID = ttlr.TopTenListInstanceID  
inner join TopTenList ttl  
 on ttl.TopTenListID = ttli.TopTenListID  
inner join TopTenListType ttlt  
 on ttlt.TopTenListTypeID = ttl.TopTenListTypeID
inner join TopTenListTypeClass ttlc
 on ttlt.TopTenListTypeClassID = ttlc.TopTenListTypeClassID   
inner join TopTenImportJob     ttij    
 on ttij.TopTenImportJobID = ttli.TopTenImportJobID    
left join TopTenListRestaurantSuppression ttlrs    
 on ttlrs.TopTenListID = ttl.TopTenListID  
 and ttlrs.RID = ttlr.RID
inner join	MetroAreaVw mv
 on	ttl.MetroAreaID	= mv.MetroAreaID
left join #TempCuisineDCNameChangeExclude tce
 on ttl.CuisineID = tce.FoodTypeID 
where ttli.isActive = 1  
 and coalesce(ttij.Status,1) = 1    
 and ttlrs.RID is null  
 and ttlr.Rank <= 10  
 and (ttl.MacroID IS NULL OR ttl.TopTenListTypeID = 22)
 order by RID
 
--Correct toptenlistIds for restaurants that have regional lists.
update tmp
set tmp.TopTenListID = ttl.TopTenListID
from #TempTopTenWithRowNumbers tmp
inner join TopTenList ttl
on tmp.MetroAreaID = ttl.MetroAreaID
and tmp.MacroID = ttl.MacroID
where tmp.ShowRegionLists = 1
and tmp.TopTenListTypeID = 22
and ttl.TopTenListTypeID = 5 -- best overall

--Limit to top 3 records
select	RID,
		ListName,
		TopTenListID,
		MetroAreaID,
		MacroID,
		OriginalListName		
from	#TempTopTenWithRowNumbers
where	DCRowRank <= @DCRowsLimit
order by RID, DCRowRank

--delete temp tables
if object_id ('tempdb..#TempTopTenWithRowNumbers') > 0   
	drop table #TempTopTenWithRowNumbers
if object_id ('tempdb..#TempCuisineDCNameChangeExclude') > 0   
	drop table #TempCuisineDCNameChangeExclude

GO

GRANT EXECUTE ON [procGetDCListsForReportFeed] TO ExecuteOnlyRole

GO 