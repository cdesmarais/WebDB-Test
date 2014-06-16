if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheTopTenRegionalLists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheTopTenRegionalLists]
GO

--**********************************************************
--** Retrieves a list of top ten regional lists, 
--** used to populate the top ten user control where
--** regional lists are turned on and on the top ten 
--** landing page where regional lists are turned on
--*********************************************************

create procedure dbo.DNCacheTopTenRegionalLists
as
set transaction isolation level read uncommitted
set nocount ON

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
	
	-- Get regional level list data	
	select		 ttl.MetroAreaid
				,ttl.TopTenListID
				,ttli.TopTenListInstanceID
				,ttltc.TopTenListTypeClassID
				,ttltc.TopTenListTypeClassName
				,ttlt.TopTenListTypeID
				,coalesce( ttl.listnameoverride, ttlt.listname )	toptenlistname
				,ttli.referallid
				,coalesce( ttli.isactive, 0 ) active
				,ttlx.ListDisplayOrder
				,ttlt.ListDisplayOrderNationalOverride
				--We always want to round the dff volume up to the nearest 100
				,((ttli.DFFVolume + 99)/100)*100 as DFFVolume
				,@JobDate as UpdateDate
				,ttl.MacroID
	from		TopTenListVW				ttl
	INNER JOIN	TopTenListVW				ttlx					
	ON			ttl.MetroAreaID = ttlx.MetroAreaID
	AND			ttl.TopTenListTypeID = ttlx.TopTenListTypeID
	AND			ttlx.MacroID				IS NULL
	left join	TopTenListInstance			ttli
	on			ttli.toptenlistid			= ttl.toptenlistid
	AND			ttli.TopTenImportJobID		= @ActiveJobID
	inner join	TopTenListType				ttlt
	on			ttlt.toptenlisttypeid		= ttl.toptenlisttypeid
	inner join	TopTenListTypeClass			ttltc
	on			ttltc.TopTenListTypeClassID = ttlt.TopTenListTypeClassID	
	inner join	MacroNeighborhoodVW			mnv
	on			ttl.MacroID					= mnv.MacroID
	INNER JOIN	MetroAreaVW					mv
	ON			mnv.MetroAreaID				= mv.MetroAreaID
	where		mv.ShowRegionLists			= 1
	and			mnv.Active					= 1
	AND			mv.Active					= 1
	AND			ttl.MacroID					IS NOT NULL
	AND			ttl.TopTenListTypeID		!= 22
	AND			@RegionalListsEnabled		= 1
	AND			( coalesce( ttli.isactive, 0 )=1 OR ( coalesce( ttli.isactive, 0 )=0 AND ttl.TopTenListTypeID in (4,5) ) )
	ORDER BY ttl.MetroAreaID, ttl.MacroID, ttlx.ListDisplayOrder
go

grant execute on [DNCacheTopTenRegionalLists] TO ExecuteOnlyRole

go


