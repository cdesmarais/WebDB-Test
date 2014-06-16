if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenImportDataVerification]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenImportDataVerification]
GO

-- =============================================
-- Author:		gguilbert
-- Create date: 2008-01-31
-- Description:	This proc is to scan a data import from
--				OTRestaurant list feeds to look for data
--				anomalies.  It will cause the top ten 
--				import job to fail if it finds any.
-- =============================================
CREATE PROCEDURE [dbo].[TopTenImportDataVerification]
(
	@JobID					int,
	@DayHorizon				int,
	@MostBookedMissing		nvarchar(2000) output	
)

AS

SET NOCOUNT ON
SET TRANSACTION isolation LEVEL READ uncommitted

declare @MinResID int
declare @MaxResID int
declare @EndDate1 datetime

set @EndDate1 = dateadd(day, datediff(day, 0, getdate()),0)  -- midnight
select @MinResID = min(resid) from Reservation where shiftdate > DATEADD(day, -(@DayHorizon + 30), @EndDate1) and DateMade > DATEADD(day, -@DayHorizon, @EndDate1)
select @MaxResID = min(resid) from Reservation where shiftdate > DATEADD(day, -31, @EndDate1) and DateMade > DATEADD(day, -1, @EndDate1)



SET @MostBookedMissing = ''


if object_id('tempdb..#temp') is not null
	drop table #temp

create table #temp (RID int)

insert	Into #temp
select	distinct rid
from	Reservation 
where	ShiftDate > DATEADD(day, -(@DayHorizon + 30), @EndDate1)
and		ResID >= @MinResID  
and		ResID < @MaxResID   
and		RStateID in (1,2,5,7) /*1 = Pending, 2 = Seated, 5 = Assumed Seated, 7 = Seated Disputed */ 
and		companyid is null /*Exclude concierge reservations*/   




----------------------------------------------------------------------
-- Step 1: Look for metros that are missing most booked lists
----------------------------------------------------------------------
declare @CountMissingMostBooked int
select @CountMissingMostBooked = count( distinct MA.MetroAreaID )
from #temp Resv

inner join RestaurantVW Rest 
on Resv.RID = Rest.RID 

inner join FoodTypes FTS with (index (FoodTypes_PK))              
on Rest.RID = FTS.RID         

inner join FoodType FT        
on FTS.FoodTypeID = FT.FoodTypeID 
and FT.LanguageID =Rest.LanguageID   

inner join NeighborhoodAVW NBH          
on Rest.NeighborhoodID = NBH.NeighborhoodID         
and NBH.LanguageID = Rest.LanguageID        

inner join MetroAreaAVW MA        
on NBH.MetroAreaID = MA.MetroAreaID        
and MA.LanguageID = Rest.LanguageID        

inner join MacroNeighborhoodAVW MNH        
on NBH.MacroID = MNH.MacroID  
and MNH.LanguageID = Rest.LanguageID        

inner join TopTenList TTL
on MA.MetroAreaID = TTL.MetroAreaID

left join TopTenListInstance TTLI
on TTL.TopTenListID = TTLI.TopTenListID

left join TopTenListRestaurantSuppression TTLRS
on Rest.RID = TTLRS.RID

where MA.active = 1
and MA.MetroAreaID <> 1
and NBH.Active = 1  
and MNH.Active = 1    
and Rest.RID not in (select ValueId from valuelookupmaster a 
                      inner join valuelookupidlist b on  
                      b.LookupID = a.LookupID 
                      where [Type] = 'WEBSERVER' and [Key] = 'TopTenRIDGlobalBlackList')  
and FTS.IsPrimary = 1    
and Rest.RestStateID = 1
and TTL.TopTenListTypeID = 1 /* Only looking at Most Booked */
and TTLRS.RID is null /* If a restaurant has been suppressed from top ten lists then do not consider */
and ISNULL(TTLI.TopTenImportJobID,@JobID) = @JobID
and ( TTLI.TopTenListID is null or
      TTLI.IsActive = 0 ) /* Null if left join is orphaned, zero if list gen determined that the metro had no data */       
and ttl.macroid IS NULL

if @CountMissingMostBooked > 0 
begin
	set @MostBookedMissing = cast( @CountMissingMostBooked as nvarchar) + N' metros are missing most booked lists.'
end


----------------------------------------------------------------------
-- Step 2: Look for core metros that don't have enough lists
-- Select all metros that are our core market, then look for those that 
-- do not have at least enough lists, value defined by ValueLookup Key: DC_MIN_CORE_LIST_COUNT, defaults to 8
----------------------------------------------------------------------
declare @CountCoreMetrosWithoutRequiredLists int
declare @MinimumRequiredLists int
set @MinimumRequiredLists = coalesce((select ValueInt from ValueLookup where LKey = 'DC_MIN_CORE_LIST_COUNT'), 8)

select				@CountCoreMetrosWithoutRequiredLists = count(*)
from				ValueLookupIdList       vlil
inner join			ValueLookupMaster       vm
on					vlil.LookupID           = vm.LookupID
and					vm.[type]               = N'WEBSERVER'
and					vm.[key]                = N'DINERS_CHOICE_CORE_METRO_LIST'
left join (
      select		ttl.MetroAreaID         
      from			TopTenListInstance		ttli
      inner join	TopTenList				ttl
      on			ttl.TopTenlistID		=  ttli.TopTenListID    
      where			ttli.TopTenImportJobID	= @JobID
      and			(ttl.MacroID			IS NULL OR 
					ttl.TopTenListTypeID	= 22)
	  and			ttli.IsActive			= 1					
      group by		ttl.MetroAreaID
      having		count(*) >= @MinimumRequiredLists
) a
on a.MetroAreaID = vlil.ValueID
where a.MetroAreaID is null


if @CountCoreMetrosWithoutRequiredLists > 0 
begin
	if len( @MostBookedMissing ) > 0 set @MostBookedMissing = @MostBookedMissing + '  '
	set @MostBookedMissing = @MostBookedMissing 
		+ cast( @CountCoreMetrosWithoutRequiredLists as nvarchar) + N' core metros do not have ' + cast(@MinimumRequiredLists as nvarchar(2)) + ' lists.'
end


----------------------------------------------------------------------
-- Step 3: Look for duplicates that would cause web cache to fail
-- on PK violation
----------------------------------------------------------------------
DECLARE @DuplicateLists INT;	
SELECT @DuplicateLists = COUNT('x') FROM (
	SELECT ttl.MetroAreaID, ttl.TopTenListID, COUNT('x') NumLists
	FROM TopTenList ttl
	INNER JOIN dbo.TopTenListInstance ttli
	ON ttl.TopTenListID = ttli.TopTenListID
	WHERE ttli.TopTenImportJobID = @JobID
	GROUP BY ttl.metroareaid, ttl.TopTenListID
	HAVING COUNT('x') > 1
) NumberOfDuplicateTopTenListIDs

if @DuplicateLists > 0 
begin	
	if len( @MostBookedMissing ) > 0 set @MostBookedMissing = @MostBookedMissing + '  '
	set @MostBookedMissing = @MostBookedMissing 
		+ cast( @DuplicateLists as nvarchar) + N' duplicate lists found'
end

if len(@MostBookedMissing) > 0 
begin
	set @MostBookedMissing = @MostBookedMissing + '  See the stored proc TopTenImportDataVerification for details on Top Ten Import job validation.'
end


GO

GRANT EXECUTE ON [TopTenImportDataVerification] TO ExecuteOnlyRole

GO
