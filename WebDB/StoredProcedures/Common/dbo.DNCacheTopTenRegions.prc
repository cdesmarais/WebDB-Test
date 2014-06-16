if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheTopTenRegions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheTopTenRegions]
GO

--*********************************************************
--** Retrieves a list of top ten regions and the list 
--** counts associated with that region
--*********************************************************

create procedure dbo.DNCacheTopTenRegions
as
set transaction isolation level read uncommitted
set nocount on

declare @ActiveJobID INT, @RegionalListsEnabled INT

--Default regional lists off
set @RegionalListsEnabled = 0

select			@ActiveJobID	= ttij.TopTenImportJobID				
from			TopTenImportJob ttij
where			ttij.Status = 1

select			@RegionalListsEnabled = coalesce(ValueInt,0)
from			dbo.ValueLookup 
where			LKey = 'TTRegionalListsEnabled'

select			 ttl.MetroAreaid
				,ttl.MacroID
				,mnv.MacroName
				,mnv.Sortorder
				,count(ttli.TopTenListID) MacroTopTenListCount
from			ActiveMacroNeighborhoodVW	mnv
inner join		dbo.MetroAreaVW				mv
on				mnv.MetroAreaID				= mv.MetroAreaID
and				mv.ShowRegionLists			= 1
inner join		TopTenListVW				ttl
on				mnv.MacroID					= ttl.MacroID
left join		TopTenListInstance			ttli
on				ttli.toptenlistid			= ttl.toptenlistid
and				ttli.TopTenImportJobID		= @ActiveJobID
where			mnv.Active					= 1	
and				mv.Active					= 1
and				ttl.TopTenListTypeID		!= 22
and				@RegionalListsEnabled		= 1
and				isnull(ttli.IsActive,1)		= 1
group by		ttl.MetroAreaid, ttl.MacroID, mnv.MacroName, mnv.Sortorder
order by		ttl.MetroAreaID, mnv.Sortorder
	
go

grant execute on [DNCacheTopTenRegions] TO ExecuteOnlyRole

go