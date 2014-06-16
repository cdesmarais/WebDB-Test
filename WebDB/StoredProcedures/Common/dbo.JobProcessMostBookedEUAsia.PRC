  
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessMostBookedEUAsia]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessMostBookedEUAsia]
go

create procedure dbo.JobProcessMostBookedEUAsia  
(  
  @DayHorizon int = 7  
)  
as  
set nocount on  
set transaction isolation level read uncommitted  
  
--Synchronize metro level lists, this will only sync MostBooked  
exec TopTenListSynchronizeMetroList  
  
--Where ShowRegionLists=1 in MetroArea, synchronize the  
--TopTenList table with the metro level lists  
exec TopTenListSynchronizeRegionListEUAsia  
  
-- Get the Start Date and End Dates based on the DayHorizon parameter value          
declare @StartDate as datetime          
declare @EndDate as datetime          
  
-- set the start and end date  
set @StartDate = convert(varchar,  getdate() - @DayHorizon, 101)  
set @EndDate = convert(varchar,  getdate() - 1, 101)      
        
-- Clean up any temp objects that might cause an error  
if object_id('tempdb..#TempMetroLists') is not null drop table #TempMetroLists  
if object_id('tempdb..#TempMacroLists') is not null drop table #TempMacroLists  
  
create table #TempMetroLists (  
metroid int,  
metrorank int,  
rid int)  
  
create table #TempMacroLists (  
macroid int,  
macrorank int,  
rid int)  
  
--Populate the metro most booked lists  
insert   #TempMetroLists (metroid, metrorank, rid)  
select   ma.MetroAreaID,  
    row_number() over (partition by ma.MetroAreaID order by count(resv.rid) desc) as MetroRank,  
    rest.RID  
from   MetroArea ma  
inner join  [MacroNeighborhood] mnh   
on    ma.[MetroAreaID] = mnh.[MetroAreaID]  
inner join  [Neighborhood] nbh   
on    ma.[MetroAreaID] = nbh.[MetroAreaID] AND mnh.[MacroID] = nbh.[MacroID]  
inner join  [Restaurant] rest   
on    nbh.[NeighborhoodID] = rest.[NeighborhoodID]  
inner join  [Reservation] resv   
on    rest.[RID] = resv.[RID]   
where        resv.companyid is null /*Exclude concierge reservations*/     
and    resv.DateMade >= @StartDate    
and    resv.DateMade < @EndDate + 1  
and    resv.ShiftDate >= dateadd(day,-30, @StartDate) --Provides a hint to use only certain partitions for the reso view     
and    resv.RStateID in (1,2,5,7) /*1 = Pending, 2 = Seated, 5 = Assumed Seated, 7 = Seated Disputed */    
and    (ma.active = 1 or ma.MetroAreaID=1) /*explicitly added Demoland metroarea*/  
and    nbh.Active = 1    
and    mnh.Active = 1      
and    rest.RID not in (select ValueId from valuelookupmaster a   
     inner join valuelookupidlist b on    
     b.LookupID = a.LookupID   
     where [Type] = 'WEBSERVER' and [Key] = 'TopTenRIDGlobalBlackList')    
and    rest.restStateID != 4  
group by  ma.MetroAreaID, rest.RID  
  
--Populate macro most booked lists  
insert   #TempMacroLists (macroid, macrorank, rid)  
select   mnh.MacroID,   
    row_number() over (partition by mnh.MacroID order by count(resv.rid) desc) as MacroRank,  
    rest.RID  
from    [MacroNeighborhood] mnh    
inner join  [Neighborhood] nbh   
on    mnh.[MacroID] = nbh.[MacroID]    
inner join  [Restaurant] rest   
on    nbh.[NeighborhoodID] = rest.[NeighborhoodID]  
inner join  [Reservation] resv   
on    rest.[RID] = resv.[RID]  
where   resv.companyid is null /*Exclude concierge reservations*/     
and    resv.DateMade >= @StartDate    
and    resv.DateMade < @EndDate + 1  
and    resv.ShiftDate >= dateadd(day,-30, @StartDate) --Provides a hint to use only certain partitions for the reso view         
and    resv.RStateID in (1,2,5,7) /*1 = Pending, 2 = Seated, 5 = Assumed Seated, 7 = Seated Disputed */    
and    (mnh.active = 1 or mnh.MetroAreaID=1) /*explicitly added Demoland metroarea*/  
and    nbh.Active = 1         
and    rest.RID not in (select ValueId from valuelookupmaster a   
     inner join valuelookupidlist b on    
     b.LookupID = a.LookupID   
     where [Type] = 'WEBSERVER' and [Key] = 'TopTenRIDGlobalBlackList')    
and    rest.restStateID != 4   
group by  mnh.MacroID, rest.RID  


-- Clean up any temp objects that might cause an error  
if object_id('tempdb..#TempPOPMetroLists') is not null drop table #TempPOPMetroLists  
if object_id('tempdb..#TempPOPMacroLists') is not null drop table #TempPOPMacroLists  

create table #TempPOPMetroLists (  
metroid int,  
metrorank int,  
rid int)  
  
create table #TempPOPMacroLists (  
macroid int,  
macrorank int,  
rid int)  
  
--Populate the metro most POP booked lists  
insert   #TempPOPMetroLists (metroid, metrorank, rid)  
select   ma.MetroAreaID,  
    row_number() over (partition by ma.MetroAreaID order by count(resv.rid) desc) as MetroRank,  
    rest.RID  
from   MetroArea ma  
inner join  [MacroNeighborhood] mnh   
on    ma.[MetroAreaID] = mnh.[MetroAreaID]  
inner join  [Neighborhood] nbh   
on    ma.[MetroAreaID] = nbh.[MetroAreaID] AND mnh.[MacroID] = nbh.[MacroID]  
inner join  [Restaurant] rest   
on    nbh.[NeighborhoodID] = rest.[NeighborhoodID]  
inner join  [Reservation] resv   
on    rest.[RID] = resv.[RID]   
where        resv.companyid is null /*Exclude concierge reservations*/     
and    resv.IncentiveId is not null
and    resv.DateMade >= @StartDate    
and    resv.DateMade < @EndDate + 1  
and    resv.ShiftDate >= dateadd(day,-30, @StartDate) --Provides a hint to use only certain partitions for the reso view     
and    resv.RStateID in (1,2,5,7) /*1 = Pending, 2 = Seated, 5 = Assumed Seated, 7 = Seated Disputed */    
and    (ma.active = 1 or ma.MetroAreaID=1) /*explicitly added Demoland metroarea*/  
and    nbh.Active = 1    
and    mnh.Active = 1      
and    rest.RID not in (select ValueId from valuelookupmaster a   
     inner join valuelookupidlist b on    
     b.LookupID = a.LookupID   
     where [Type] = 'WEBSERVER' and [Key] = 'TopTenRIDGlobalBlackList')    
and    rest.restStateID != 4  
group by  ma.MetroAreaID, rest.RID  
  
--Populate macro most POP booked lists  
insert   #TempPOPMacroLists (macroid, macrorank, rid)  
select   mnh.MacroID,   
    row_number() over (partition by mnh.MacroID order by count(resv.rid) desc) as MacroRank,  
    rest.RID  
from    [MacroNeighborhood] mnh    
inner join  [Neighborhood] nbh   
on    mnh.[MacroID] = nbh.[MacroID]    
inner join  [Restaurant] rest   
on    nbh.[NeighborhoodID] = rest.[NeighborhoodID]  
inner join  [Reservation] resv   
on    rest.[RID] = resv.[RID]  
where   resv.companyid is null /*Exclude concierge reservations*/     
and    resv.IncentiveId is not null
and    resv.DateMade >= @StartDate    
and    resv.DateMade < @EndDate + 1  
and    resv.ShiftDate >= dateadd(day,-30, @StartDate) --Provides a hint to use only certain partitions for the reso view         
and    resv.RStateID in (1,2,5,7) /*1 = Pending, 2 = Seated, 5 = Assumed Seated, 7 = Seated Disputed */    
and    (mnh.active = 1 or mnh.MetroAreaID=1) /*explicitly added Demoland metroarea*/  
and    nbh.Active = 1         
and    rest.RID not in (select ValueId from valuelookupmaster a   
     inner join valuelookupidlist b on    
     b.LookupID = a.LookupID   
     where [Type] = 'WEBSERVER' and [Key] = 'TopTenRIDGlobalBlackList')    
and    rest.restStateID != 4   
group by  mnh.MacroID, rest.RID  


  
--------------------------------------------------------------------------  
-- Start inserting into TopTen tables  
--------------------------------------------------------------------------  
begin transaction  
  
  
--------------------------------------------------------------------------  
-- begin TopTenImportJob  
--------------------------------------------------------------------------  
  
declare   @TopTenImportJobID as int  
  
insert into  TopTenImportJob   
(  
    CreateDate,  
    [Status]  
)   
values   
(   
    getdate(),  
    3 --Status set to "New", a follow on job will update to active.  
)   
  
set @TopTenImportJobID = @@identity  
  
--------------------------------------------------------------------------  
-- end TopTenImportJob  
--------------------------------------------------------------------------  
  
if (@@error <> 0)  
 goto general_error  
  
--------------------------------------------------------------------------  
-- begin TopTenListInstance  
-- creates a new set of lists to reflect what's in the TopTenList table.  
--------------------------------------------------------------------------  
  
insert into  TopTenListInstance (  
    TopTenListID,  
    TopTenImportJobID,  
    IsActive,  
    ReferallID,  
    DFFVolume  
)   
select   TopTenListID,  
    @TopTenImportJobID as TopTenImportJobID,  
    0 as IsActive,  
    10 as ReferallID,  
    0 as DFFVolume  
from   TopTenList  
where   TopTenListTypeID in (1, 2)  -- MostBooked & Most Booked 1000-Point Tables types

  
--------------------------------------------------------------------------  
-- end TopTenListInstance  
--------------------------------------------------------------------------  
  
if (@@error <> 0)  
 goto general_error  
  
--------------------------------------------------------------------------  
-- begin TopTenListRestaurant  
--------------------------------------------------------------------------  
   
--Most Booked Metros  
insert into  TopTenListRestaurant  
(  
    TopTenListInstanceID,  
    RID,  
    [Rank]  
)   
select   ttli.TopTenListInstanceID,   
    tml.rid,   
    tml.MetroRank  
from   #TempMetroLists tml  
inner join  TopTenList ttl  
on    tml.metroid = ttl.MetroAreaID  
inner join  TopTenListInstance ttli  
on    ttl.TopTenListID = ttli.TopTenListID  
where   ttl.MacroID is null  
and    ttli.TopTenImportJobID = @TopTenImportJobID  
and    tml.metrorank <= 20  
and    ttl.TopTenListTypeId = 1  -- MostBooked 
  
--Most Booked Macros  
insert into  TopTenListRestaurant   
(  
    TopTenListInstanceID,  
    RID,  
    [Rank]  
)  
select   ttli.TopTenListInstanceID,  
    tmal.rid,  
    tmal.macrorank  
from   #TempMacroLists tmal  
inner join  Restaurant r  
on    tmal.rid = r.RID  
inner join  Neighborhood n  
on    r.NeighborhoodID = n.NeighborhoodID  
inner join  TopTenList ttl  
on    n.MacroID = ttl.MacroID  
and    tmal.macroid = ttl.MacroID  
inner join  TopTenListInstance ttli  
on    ttl.TopTenListID = ttli.TopTenListID  
where   ttl.MacroID is not null  
and    ttli.TopTenImportJobID = @TopTenImportJobID  
and    tmal.macrorank <= 20  
and    ttl.TopTenListTypeId = 1  -- MostBooked 

-- Most Booked POP Metros  
insert into  TopTenListRestaurant  
(  
    TopTenListInstanceID,  
    RID,  
    [Rank]  
)   
select   ttli.TopTenListInstanceID,   
    tml.rid,   
    tml.MetroRank  
from   #TempPOPMetroLists tml  
inner join  TopTenList ttl  
on    tml.metroid = ttl.MetroAreaID  
inner join  TopTenListInstance ttli  
on    ttl.TopTenListID = ttli.TopTenListID  
where   ttl.MacroID is null  
and    ttli.TopTenImportJobID = @TopTenImportJobID  
and    tml.metrorank <= 20  
and    ttl.TopTenListTypeId = 2  --  Most Booked 1000-Point Tables
  
-- Most Booeked POP Macros  
insert into  TopTenListRestaurant   
(  
    TopTenListInstanceID,  
    RID,  
    [Rank]  
)  
select   ttli.TopTenListInstanceID,  
    tmal.rid,  
    tmal.macrorank  
from   #TempPOPMacroLists tmal  
inner join  Restaurant r  
on    tmal.rid = r.RID  
inner join  Neighborhood n  
on    r.NeighborhoodID = n.NeighborhoodID  
inner join  TopTenList ttl  
on    n.MacroID = ttl.MacroID  
and    tmal.macroid = ttl.MacroID  
inner join  TopTenListInstance ttli  
on    ttl.TopTenListID = ttli.TopTenListID  
where   ttl.MacroID is not null  
and    ttli.TopTenImportJobID = @TopTenImportJobID  
and    tmal.macrorank <= 20  
and    ttl.TopTenListTypeId = 2  -- Most Booked 1000-Point Tables

--------------------------------------------------------------------------  
-- end TopTenListRestaurant  
--------------------------------------------------------------------------  
  
if (@@error <> 0)  
 goto general_error  
  
commit transaction  
if object_id('tempdb..#TempMetroLists') is not null drop table #TempMetroLists  
if object_id('tempdb..#TempMacroLists') is not null drop table #TempMacroLists  
if object_id('tempdb..#TempPOPMetroLists') is not null drop table #TempPOPMetroLists  
if object_id('tempdb..#TempPOPMacroLists') is not null drop table #TempPOPMacroLists  
return (0)  
  
general_error:  
 if object_id('tempdb..#TempMetroLists') is not null drop table #TempMetroLists  
 if object_id('tempdb..#TempMacroLists') is not null drop table #TempMacroLists  
 if object_id('tempdb..#TempPOPMetroLists') is not null drop table #TempPOPMetroLists  
 if object_id('tempdb..#TempPOPMacroLists') is not null drop table #TempPOPMacroLists 
 rollback transaction  
 return(1)  
  
  
  
go


grant execute on [JobProcessMostBookedEUAsia] to ExecuteOnlyRole

go

