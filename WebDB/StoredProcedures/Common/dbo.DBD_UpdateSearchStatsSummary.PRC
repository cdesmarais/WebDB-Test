if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_UpdateSearchStatsSummary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_UpdateSearchStatsSummary]
GO


CREATE PROCEDURE dbo.DBD_UpdateSearchStatsSummary

  
As
--SET NOCOUNT ON
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @TimeOuts as int, @NoConnection as int, @Errors as int, @Cutoffs as int
Declare @BlockedSearches as int, @NoAvailability as int, @TimesAvailable as int, @Total as int
Declare @TotalSearches as int, @AverageResponseTime as dec(5,2), @MaxResponseTime as dec(5,2)
Declare @Resos as int, @Covers as int

--truncate table SearchStatsSummary
Declare @curDT datetime
Declare @startDT datetime
set @curDT = getdate()
set @startDT = dateadd(mi, -5, @curDT)


--Optimize to search for only tail end of the searchstats table and reservation records--
declare @sid int, @resid int, @runit int, @unit int
declare @dt datetime
set @dt = getdate()
set @unit = 200
set @runit =500


Select	@Resos = Count(ResiD), 
		@Covers = coalesce(sum(coalesce(PartySize,0)),0)
from	reservation 
where	
		-- Trick to Quickly issolate data to appropriate partition; 
		-- Impossible for a Reso to have a datemade that is smaller than the shiftdate; 
		-- there are some cases when an ERB change trickles in late but there is a 30 day limit on these
		-- However it is possible for a reso to have a ShiftDate much greater than datemade (reso can be made far into the future)
		ShiftDate >= dateadd(dd, -30, @startDT)
and		DateMade >= @startDT
and		rstateid = 1

--Now do the same tuning method for Searchstats table

select @sid = max(searchstatsid) - @unit from searchstats


while(exists (select datets from searchstats 
               where searchstatsid = @sid and datediff(mi, datets, @dt) < 20)  
     )
begin
      --*****************
      --** Previous Searchstat ID was < 20 minutes back
      --** Lookback again
      --*****************
      set @sid = @sid - @unit
end





Select 
@TotalSearches = sum(TotalSearches),
@AverageResponseTime = sum(TotERBElapsTimeMS)/sum(TotalSearches)/1000.00,
@MaxResponseTime = max(MaxERBElapsTimeMS)/1000.00,
@TimeOuts = sum(Status_TimeOuts), 
@NoConnection = sum(Status_NoConnection-Status_TimeOuts), 
@Errors = sum(Status_Errors), 
@Cutoffs = sum(Status_CuttOffs), 
@BlockedSearches = sum(Status_BlockedSearches),
@NoAvailability = sum(Status_NoAvailability-(Status_NoConnection+Status_Errors+Status_CuttOffs)), 
@TimesAvailable = sum(Status_TimesAvailable), 
@Total = sum(Status_NoAvailability+Status_TimesAvailable)
from searchStats 
where searchstatsid > @sid and restaurantID = -1 
and dateTS >= @startDT and dateTS < @curDT
and hostname != 'OTStage' -- Do not include staging server

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (1,@TimeOuts,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (2,@NoConnection,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (3,@Errors,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (4,@Cutoffs,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (5,@BlockedSearches,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (6,@NoAvailability,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (7,@TimesAvailable,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (8,@Total,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (9,@Resos,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (10,@Covers,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (11,@TotalSearches,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (12,@AverageResponseTime,@curDT)

Insert into SearchStatsSummary (SearchStatTypeID, SearchStat, DateAdded)
VALUES (13,@MaxResponseTime,@curDT)


GO
GRANT EXECUTE ON [DBD_UpdateSearchStatsSummary] TO ExecuteOnlyRole

GO
