


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_GetMRNCValues]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_GetMRNCValues]
go



/*
	TopTen generator uses this proc while feedlist name generation.
	If the feedtemplate for a ruleset consists either of metro,region,neighborhood,cuisine values
	then it is replaced by the exact value while feed list generation. 
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/


create procedure [dbo].[TopTen_GetMRNCValues]
(
      @MetroId int,
	@RegionId int,
	@NbHoodId int,
	@CuisineId int 	
)
AS

begin


SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select
	MA.MetroAreaName as Metro
	,MNBH.MacroName as Region 
	,NBH.NbhoodName as Neighborhood
	,(select top 1 foodtype
		from FoodType
		inner join		dbo.DBUserDistinctLanguageVW db 
		on				db.languageid = FoodType.LanguageID
		where FoodTypeId = case when @CuisineId =0 then FoodTypeId else @CuisineId end ) as Cuisine	
	from 
		NeighborhoodVW AS NBH		
		    inner join MetroAreaVW MA
		        on NBH.MetroAreaID = MA.MetroAreaID 	
		
		    inner join MacroNeighborhoodVW  MNBH
		        on NBH.MacroID = MNBH.MacroID 
	where 
	(MA.active = 1 or MA.MetroAreaID=1) -- allow Demoland to pass
	and NBH.Active = 1
	and MNBH.Active = 1 
	and	MA.MetroAreaID = 
	    case 
	        when @MetroId =0 
	            then MA.MetroAreaID 
	        else @MetroId 
	        end
	and	MNBH.MacroID = 
	    case 
	        when @RegionId =0 
	            then MNBH.MacroID 
            else @RegionId 
            end  
	
	and	NBH.NeighborhoodID= 
	    case 
	        when @NbHoodId =0 
	            then NBH.NeighborhoodID 
        else @NbHoodId 
        end   
end

go

grant execute on [TopTen_GetMRNCValues] to ExecuteOnlyRole
go


