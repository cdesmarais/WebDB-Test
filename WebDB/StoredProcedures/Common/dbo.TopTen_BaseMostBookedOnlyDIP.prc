


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_BaseMostBookedOnlyDIP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_BaseMostBookedOnlyDIP]
go

/*
	Used as the base procedure to generate most-booked DIP type of lists. Content owned by India team, 
	please notify asaxena@opentable.com if changing.
*/

create procedure dbo.TopTen_BaseMostBookedOnlyDIP
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

-- get steak id and name 
-- Get food type id and food type name value  
-- Note: FoodType = 'steak' and FoodType = 'stakehouse' should be treated as same. Here we are assuming 
-- that this rule applies only to North America (language Id = 1). In future if similar kind
-- of exceptions needs to added for other cusines as well, then this stored proc should be modified 
-- to include those exceptions.

SELECT @SteakFoodTypeId=FoodTypeID
    ,@SteakFoodTypeName=FoodType 
FROM FoodType 
WHERE lower(FoodType) = 'steak'
and LanguageID = 1

-- Get the Start Date and End Dates based on the DayHorizon parameter value
declare @StartDate as datetime
declare @EndDate as datetime
declare @ShiftStartDate datetime


-- set the start and end date
set @StartDate = CONVERT(VARCHAR,  getdate() - @DayHorizon, 101)       
set @EndDate = CONVERT(VARCHAR,  getdate() - 1, 101)   

-- Add filter on shift date to get advantage of partition key. 
-- Consider only those reservations whose Shift date > (Start date - 6 Months).   
set @ShiftStartDate = DATEADD(month,-6,@startdate)

-- Safe check, drop #Reservation table if already exists
if object_id('tempdb..#Reservation') is not null 
	drop table #Reservation
	
-- Create temporary table to hold the reservation data.
-- Temporary table is used to get the advantage of the partition key
create table #Reservation
(
	ResID int not null
	,RID int not null
	,RStateID int not null
	,ShiftDate datetime not null
	,dateMade datetime not null	
	,CONSTRAINT [PK_Reservation_ResID_ShiftDate] PRIMARY KEY
	(
		ResID ASC
		,ShiftDate ASC
	)
)

insert into #Reservation
select
	ResID
	,RID
	,RStateID
	,ShiftDate
	,dateMade
from
	Reservation
where	
	shiftdate > @ShiftStartDate 
	and CompanyID is null /*Exclude concierge reservations*/
	and RStateID in (1,2,5,7) /*1 = Pending, 2 = Seated, 5 = Assumed Seated, 7 = Seated Disputed */ 
    /* DIP Condition - restaurant must have non null incentiveid, this is due to recent changes, where anon user DIP resos also get billed and are tagged as such. So its not 
    enough to look at the points. This is consistent with how these resos get billed. 
    */
	and incentiveID is not NULL
	and DateMade >= @StartDate  
    and DateMade < @EndDate + 1  	
	
select 
		Rest.RID, 
		Rest.RName,
		NBH.NeighborhoodID,
		NBH.NbhoodName as Neighborhood,
		MA.MetroAreaID as MetroID,
		MA.MetroAreaName as Metro, 
		MNH.MacroID as RegionID,
		MNH.MacroName as Region,
		count(Resv.RID) as Reservations,
		CuisineId = case 
			when lower(FT.FoodType) = 'steakhouse' then  @SteakFoodTypeId
			else FTS.FoodTypeID
		end,
		Cuisine = case 
			when lower(FT.FoodType) = 'steakhouse' then  @SteakFoodTypeName
			else FT.FoodType  
		end

from #Reservation Resv

inner join RestaurantVW Rest
on Resv.RID = Rest.RID 

inner join FoodTypes FTS with (index (FoodTypes_PK))   
on Rest.RID = FTS.RID 

inner join FoodType FT
on FTS.FoodTypeID = FT.FoodTypeID and FT.LanguageID = Rest.LanguageID

inner join NeighborhoodAVW NBH  
on Rest.NeighborhoodID = NBH.NeighborhoodID 
and NBH.LanguageID = Rest.LanguageID  

inner join MetroAreaAVW MA
on NBH.MetroAreaID = MA.MetroAreaID
and MA.LanguageID = Rest.LanguageID  

inner join MacroNeighborhoodAVW MNH
on NBH.MacroID = MNH.MacroID
and MNH.LanguageID = Rest.LanguageID 

where   
	(MA.active = 1 or MA.MetroAreaID=1) /*explicitly added Demoland metroarea*/ 
	and NBH.Active = 1
	and MNH.Active = 1	
	and Rest.RID not in (select ValueId from valuelookupmaster a 
                         inner join valuelookupidlist b 
                         on b.LookupID = a.LookupID	
                         where [Type] = 'WEBSERVER' 
                         and [Key] = 'TopTenRIDGlobalBlackList')
	and FTS.IsPrimary = 1  
	and charindex(',' + cast(MA.MetroAreaID as nvarchar) + ',', ',' + @MetroList + ',')>0
	and charindex(',' + cast(Rest.RestStateID as nvarchar) + ',', ',' + @Reststatelist + ',')>0
	and not (charindex(',' + cast(Rest.RID as nvarchar) + ',', ',' + isnull(@RIDBlackList,'') + ',')>0)

group by 
		Rest.RID,
		Rest.RName,
		NBH.NeighborhoodID,
		NBH.NbhoodName,
		MA.MetroAreaID,
		MA.MetroAreaName , 
		MNH.MacroID,
		MNH.MacroName,
		FT.FoodType,
		FTS.FoodTypeID 

--Clean up #Reservation before exit
if object_id('tempdb..#Reservation') is not null 
	drop table #Reservation

go

grant execute on [TopTen_BaseMostBookedOnlyDIP] to ExecuteOnlyRole
go



