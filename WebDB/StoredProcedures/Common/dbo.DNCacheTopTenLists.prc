if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheTopTenLists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheTopTenLists]
GO

--*********************************************************
--** Retrieves a list of top ten lists, used to populate the
--** top ten user control and the top ten landing page
--*********************************************************

create procedure dbo.DNCacheTopTenLists
as
set transaction isolation level read uncommitted
set nocount ON

/*
	This stored procedure is used to cache metro level TopTen lists only.
	The first portion of the query (before the union) is for querying all
	metros where region lists should not be displayed.  The second portion
	is for the metros where the region lists should be displayed.  The singular
	override switch @RegionalListsEnabled will cause all metro level lists
	to look as if they should not be displaying region level lists.
	
	The stored proc DNCacheTopTenRegionalLists will cache the TopTen records
	for the regional lists.
*/
Declare @ActiveJobID INT, @JobDate DATETIME, @RegionalListsEnabled INT

--Default regional lists off
SET @RegionalListsEnabled = 0

SELECT			@ActiveJobID	= ttij.TopTenImportJobID,
				@JobDate		= ttij.CreateDate
FROM			TopTenImportJob ttij
WHERE			ttij.Status = 1

SELECT			@RegionalListsEnabled = coalesce(ValueInt,0)
FROM			dbo.ValueLookup 
WHERE			LKey = 'TTRegionalListsEnabled'
	
	-- Metro level lists for metros with ShowRegionLists turned off
	select		 ttl.MetroAreaid				
				,ttl.TopTenListID
				,ttli.TopTenListInstanceID
				,ttltc.TopTenListTypeClassID
				,ttltc.TopTenListTypeClassName
				,ttlt.TopTenListTypeID
				,coalesce( ttl.listnameoverride, ttlt.listname )	toptenlistname
				,ttli.referallid
				,coalesce( ttli.isactive, 0 ) active
				,ttl.ListDisplayOrder
				,ttlt.ListDisplayOrderNationalOverride
				--We always want to round the dff volume up to the nearest 100
				,((ttli.DFFVolume + 99)/100)*100 as DFFVolume
				,@JobDate as UpdateDate
				,ttl.MacroID
	from		TopTenListVW				ttl
	left join	TopTenListInstance			ttli
	on			ttli.toptenlistid			= ttl.toptenlistid
	AND			ttli.TopTenImportJobID		= @ActiveJobID
	inner join	TopTenListType				ttlt
	on			ttlt.toptenlisttypeid		= ttl.toptenlisttypeid
	inner join	TopTenListTypeClass			ttltc
	on			ttltc.TopTenListTypeClassID = ttlt.TopTenListTypeClassID	
	left join	MacroNeighborhoodVW			mnv
	on			ttl.MacroID					= mnv.MacroID
	INNER JOIN	MetroAreaVw mv
	ON			ttl.MetroAreaID				= mv.MetroAreaID
	where		coalesce(mnv.Active,1)		= 1
	AND			mv.Active					= 1
	AND			(mv.ShowRegionLists			= 0 OR 
				 @RegionalListsEnabled = 0)
	AND			(ttl.MacroID IS NULL OR ttl.TopTenListTypeID = 22)
	AND ( coalesce( ttli.isactive, 0 )=1 OR ( coalesce( ttli.isactive, 0 )=0 AND ttlt.TopTenListTypeID in (4,5) ) ) -- active or in best overall and best food	
	UNION ALL
	-- Metro Level lists with ShowRegionLists turned on
	select		 ttl.MetroAreaid
				,ttl.TopTenListID
				,ttli.TopTenListInstanceID
				,ttltc.TopTenListTypeClassID
				,ttltc.TopTenListTypeClassName
				,ttlt.TopTenListTypeID
				,coalesce( ttl.listnameoverride, ttlt.listname )	toptenlistname
				,ttli.referallid
				,coalesce( ttli.isactive, 0 ) active
				,ttl.ListDisplayOrder
				,ttlt.ListDisplayOrderNationalOverride
				--We always want to round the dff volume up to the nearest 100
				,((ttli.DFFVolume + 99)/100)*100 as DFFVolume
				,@JobDate as UpdateDate
				,NULL AS MacroID
	from		TopTenListVW				ttl
	left join	TopTenListInstance			ttli
	on			ttli.toptenlistid			= ttl.toptenlistid
	AND			ttli.TopTenImportJobID		= @ActiveJobID
	inner join	TopTenListType				ttlt
	on			ttlt.toptenlisttypeid		= ttl.toptenlisttypeid
	inner join	TopTenListTypeClass			ttltc
	on			ttltc.TopTenListTypeClassID = ttlt.TopTenListTypeClassID	
	left join	MacroNeighborhoodVW			mnv
	on			ttl.MacroID					= mnv.MacroID
	INNER JOIN	MetroAreaVw mv
	ON			ttl.MetroAreaID				= mv.MetroAreaID 
	where		coalesce(mnv.Active,1)		= 1
	AND			mv.Active					= 1
	AND			mv.ShowRegionLists			= 1 
	AND			@RegionalListsEnabled		= 1
	AND			ttl.MacroID					IS NULL
	and			coalesce(mnv.Active,1)		= 1
	AND			(ttl.MacroID IS NULL OR ttl.TopTenListTypeID = 22)
	AND ( coalesce( ttli.isactive, 0 )=1 OR ( coalesce( ttli.isactive, 0 )=0 AND ttlt.TopTenListTypeID in (4,5) ) ) -- active or best food	

go

grant execute on [DNCacheTopTenLists] TO ExecuteOnlyRole

go


