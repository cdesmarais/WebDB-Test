

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_GetMetroRegionNBHoodData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_GetMetroRegionNBHoodData]
go


/*
	The TopTen generator relies on this proc pull back geo information from the consumer database. 
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

create procedure [dbo].[TopTen_GetMetroRegionNBHoodData] 
      @MetroId varchar(1000) 
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

begin


select  MA.MetroAreaID AS MetroID
	,MNBH.MacroID AS RegionID
	,NBH.NeighborhoodID
	
	from 
		NeighborhoodVW AS NBH
		
		inner join MetroAreaVW MA
		    on NBH.MetroAreaID = MA.MetroAreaID 
	
		inner join MacroNeighborhoodVW  MNBH
		    on NBH.MacroID = MNBH.MacroID 
	where 
	(MA.active = 1 or MA.MetroAreaID=1) /*explicitly added Demoland metroarea*/
	and NBH.Active = 1
	and MNBH.Active = 1 
	and	charindex(',' + cast( MA.MetroAreaID AS nvarchar) + ',', ',' + @MetroId + ',')>0
	
	order by MetroID
	        ,RegionID 
	        ,NeighborhoodID 
end

go

grant execute on [TopTen_GetMetroRegionNBHoodData] to ExecuteOnlyRole
go


