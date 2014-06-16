if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosActiveBRUPBombardmentCheck]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosActiveBRUPBombardmentCheck]
GO

CREATE Procedure [dbo].[NagiosActiveBRUPBombardmentCheck]
As

-- 
-- This proc is used to generate a Nagios alert for the case where 
-- one or more ERBs are sending repeated identical BRUP messages to the website.
-- The test is whether for any given restaurant ( RID ) there is a recent 
-- (latest message occurring within past 24-hrs ) episode of more than 10 identical messages 
-- in the BRUP queue (either processed or unprocessed).
--
-- The motivation for this test is the potential for the ERB Listener to fail to decode a website 
-- acknowledgement of a successfully received BRUP message.  On failure, the ERB will re-send the 
-- original message on an exponential decay "backoff" schedule with no limit on potential total number of resends.
--
-- DEPRECATED : The reason for this test is to detect re-occurrence of the pre-7.0.10 Listener bug
-- that could cause hammer retry of BRUP transmissions
-- as a result of a misconfigured timer.
--

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


-- the count of identical repeated BRUP messages necessary to qualify for an alert
declare		@RepeatedMessageThreshold				int
set			@RepeatedMessageThreshold				= 10

-- the lookback window length in days for BRUP message CreateDt that qualify for an alert
declare		@EarliestCreateDateWindowInDays			int
set			@EarliestCreateDateWindowInDays			= 30

-- the lookback window length in hours of allowable max(CreateDt) that qualifies for an alert
declare		@EarliestMaxCreateDateWindowInHours		int
set			@EarliestMaxCreateDateWindowInHours		= 24

-- the begin date-time of the window of allowable CreateDt
declare		@QualifyingWindowBeginDate				datetime
set			@QualifyingWindowBeginDate				= DATEADD(day, -@EarliestCreateDateWindowInDays, GETDATE())

-- the begin date-time of the window of allowable max(CreateDt) 
declare		@EarliestAllowableMaxCreateDt			datetime
set			@EarliestAllowableMaxCreateDt			= DATEADD(hour, -@EarliestMaxCreateDateWindowInHours, GETDATE())

-- 
-- first, we collect repeater episodes:
-- an episide occurs when since @QualifyingWindowBeginDate
-- there have been at least [@RepeatedMessageThreshold] occurrences of a 
-- BRUPMessage with identical first 100 chars
--
select		RID, 
			SUBSTRING(BRUPMessage, 1, 100) partial_message,
			COUNT(*) repeat_count, 
			MAX(CreateDt) max_date
into		#RepeaterEpisodes
from		BRUPQueue (nolock)
where		CreateDt >= @QualifyingWindowBeginDate
group by	RID, 
			SUBSTRING(BRUPMessage, 1, 100)
having		COUNT(*) >= @RepeatedMessageThreshold
order by	repeat_count desc


-- 
-- collect distinct RIDs that experienced a repeated BRUP message episode;  
-- for each RID, sum-up total count repeated BRUP messages over all episodes
--
select		RID,
            SUM(repeat_count) sum_repeat_count
into		#RIDsWithRepeaterEpisodes
from        #RepeaterEpisodes 
where       max_date >= @EarliestAllowableMaxCreateDt
group by    RID


-- count of the number of restaurants sending repeated BRUP messages
declare    @RIDCount		int

-- Nagios status & message
declare    @Status				tinyint
declare    @Message				varchar(1000)


select	   @RIDCount = COUNT(*) from #RIDsWithRepeaterEpisodes

if @RIDCount = 0
begin
    -- no repeaters: no alert
    set @Status = 0
    set @Message = ''
end
else
begin
    -- we found repeaters, so must compose a status = 2 alert; 
    -- build message enumerating RIDs and corresponding total repeated message count
    set @Status = 2
    declare @RIDList varchar(4000)
    set @RIDList = ''
    -- recursive query to accumulate RIDs from the #RIDsWithRepeaterEpisodes temp table
    select      @RIDList            =  '[RID ' + CONVERT(varchar, RID) 
                                       + ' : ' + CONVERT(varchar, sum_repeat_count) + ' repeats]'
                                       + ', ' + @RIDList 
    from        #RIDsWithRepeaterEpisodes
    group by    RID, sum_repeat_count
    
    if RIGHT(@RIDList, 2) = ', '
    begin
		set @RIDList = SUBSTRING(@RIDList, 1, LEN(@RIDList))
	end
    
    set @Message = 'BRUP repeats detected : ' + @RIDList
end


exec procNagiosActiveResponse @Status, @Message


GO

GRANT EXECUTE ON [NagiosActiveBRUPBombardmentCheck] TO ExecuteOnlyRole
GRANT EXECUTE ON [NagiosActiveBRUPBombardmentCheck] TO MonitorUser

GO



