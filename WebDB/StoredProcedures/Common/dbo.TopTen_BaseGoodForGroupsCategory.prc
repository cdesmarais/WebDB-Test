


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_BaseGoodForGroupsCategory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_BaseGoodForGroupsCategory]
go

/*
	Used as the base procedure to get data for restaurants that allow larger group bookings online. Content owned by India team, 
	please notify asaxena@opentable.com if changing.
*/

create procedure dbo.TopTen_BaseGoodForGroupsCategory
(
	@MetroList  varchar(1000),
	@Reststatelist varchar(100),
	@RIDBlackList varchar(1000),
	@DayHorizon int
)
as  
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @SteakFoodTypeId as nvarchar(300)
declare @SteakFoodTypeName as nvarchar(300)

SELECT @SteakFoodTypeId=FoodTypeID
    ,@SteakFoodTypeName=FoodType 
FROM FoodType 
WHERE lower(FoodType) = 'steak'

select 
	Rest.RID , 
	Rest.RName,
	NBH.NeighborhoodID,
	NBH.NbhoodName as Neighborhood,
	MA.MetroAreaID as MetroID,
	MA.MetroAreaName as Metro, 
	MNH.MacroID as RegionID,
	MNH.MacroName as Region,
	CuisineId = case 
		when lower(FT.FoodType) = 'steakhouse' then  @SteakFoodTypeId
		else FTS.FoodTypeID
	end,
	Cuisine = case 
		when lower(FT.FoodType) = 'steakhouse' then  @SteakFoodTypeName
		else FT.FoodType
	end
		
from RestaurantVW Rest

inner join MaxOnlineOption MOOP
on Rest.MaxOnlineOptionId = MOOP.MaxOnlineOptionId

inner join FoodTypes FTS 
on Rest.RID = FTS.RID 

inner join FoodType FT 
on FTS.FoodTypeID = FT.FoodTypeID 
and FT.LanguageID = Rest.LanguageID

inner join NeighborhoodAVW NBH   
on rest.NeighborhoodID = NBH.NeighborhoodID 
and NBH.LanguageID = Rest.LanguageID  

inner join MetroAreaAVW MA
on NBH.MetroAreaID = MA.MetroAreaID
and MA.LanguageID = Rest.LanguageID  

inner join MacroNeighborhoodAVW MNH
on NBH.MacroID = MNH.MacroID
and MNH.LanguageID = Rest.LanguageID 

where (MA.active = 1 or MA.MetroAreaID=1) /*explicitly added Demoland metroarea*/ 
	and NBH.Active = 1
	and MNH.Active = 1
    and MOOP.MaxValue >= 6 /* Restaurant must accept partysize of 6 or more*/
	-- TopTen specific RID Global BlackList from the ValueLookupIDList table
	-- should not be included in output list
	and Rest.RID not in (select ValueId from valuelookupmaster a 
                        inner join valuelookupidlist b 
                        on b.LookupID = a.LookupID	
                        where [Type] = 'WEBSERVER' and [Key] = 'TopTenRIDGlobalBlackList')
    and FTS.IsPrimary = 1
	and charindex(',' + cast(MA.MetroAreaID as nvarchar) + ',', ',' + @MetroList + ',')>0
	and charindex(',' + cast(Rest.RestStateID as nvarchar) + ',', ',' + @Reststatelist + ',')>0
	and not (charindex(',' + cast(Rest.RID as nvarchar) + ',', ',' + isnull(@RIDBlackList,'') + ',')>0)


go

grant execute on [TopTen_BaseGoodForGroupsCategory] to ExecuteOnlyRole
go

