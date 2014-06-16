if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_SuppressDIP_Wrapper]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_SuppressDIP_Wrapper]
GO


-- wrapper function to primary stored proc. This wrapper was created because Akash did not want to change the primary entry 
-- point (Concierge_SuppressDIP) to include a OUTPUT param. Calling the proc from Concierge_SuppressDIP_Wrapper was throwing an error when
-- called from the website - which is why the wrapper passthru is required.. 
CREATE PROCEDURE dbo.Concierge_SuppressDIP_Wrapper
(
    @RID int,
    @ResoDateTime datetime,
    @SuppressDIP int output
)
AS

-- variable declarations
declare @theRID int,@thePromoID int
declare @theEvtStartDate datetime,@theEvtEndDate datetime
declare @theResult int,@isLunchTime int
set @theResult = 0

-- get the reso date part only..
declare @theResoDatePart datetime
set @theResoDatePart = CAST(ROUND(CAST(@ResoDateTime AS float), 0, 1) AS datetime)
--print @theResoDatePart


-- find all the active promos that this restaurant participates in for which DIP suppression is active
declare curPromoList cursor for	
	select pr.rid,pp.promoid,pp.eventstartdate,pp.eventenddate
	from promopages pp,promorests pr,restaurant r
	where pr.promoid=pp.promoid and pp.active=1 and r.rid=pr.rid 
	and pr.rid = @RID and EventEndDate >= @theResoDatePart and EventStartDate <= @theResoDatePart and pp.suppressdip=1

	OPEN curPromoList
	FETCH NEXT FROM curPromoList 
		INTO @theRID,@thePromoID,@theEvtStartDate,@theEvtEndDate
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	-- iterate over promos that matter
	-- DIP supression is ON till some "turn off" event occurs
	set @theResult = 1
	set @isLunchTime = 1

	-- check if exclusion date
	if exists(select * from promopageexclusions where promoid=@thePromoID and exclusiondate=CAST(ROUND(CAST(@ResoDateTime AS float), 0, 1) AS datetime))
		BEGIN
		-- exclusion exists for promo on given date - dont suppress DIP
		set @theResult = 0
		--print 'Hit exclusion date,dont suppress DIP.Promo is ' + cast(@thePromoID as nvarchar(5))
		END
	ELSE
		BEGIN
			-- no exclusions, check special shift level supression
			if @ResoDateTime >= ('' + cast(MONTH(@ResoDateTime) as nvarchar(2)) 
			+ '/' + cast(Day(@ResoDateTime) as nvarchar(2)) + '/' + cast(Year(@ResoDateTime) as nvarchar(4)) + ' 16:00')
			BEGIN
				-- set dinner flag..
				set @isLunchTime = 0
				--print 'Reso time is dinner'
			END
			
			-- check shift level rules
			if @isLunchTime = 1 
				BEGIN
				-- check if lunchtime supression is relaxed
				if exists (select rid from PromoDIPSupressExclusion where rid=@theRID and promoid=@thePromoID and SupressDIPLunch=0)
					BEGIN
					set @theResult = 0
					--print 'Promo does not suppress DIP during lunch,allow DIP points.Promo is ' + cast(@thePromoID as nvarchar(5))
					END
				END
			ELSE
				BEGIN
				-- check if dinner time supression is relaxed
				if exists (select rid from PromoDIPSupressExclusion where rid=@theRID and promoid=@thePromoID and SupressDIPDinner=0)
					BEGIN
					set @theResult = 0
					--print 'Promo does not suppress DIP during dinner,allow DIP points.Promo is ' + cast(@thePromoID as nvarchar(5))
					END
				END	
		END
		

	-- move ahead		
  	FETCH NEXT FROM curPromoList 
    		INTO @theRID,@thePromoID,@theEvtStartDate,@theEvtEndDate
	END
	

	-- Cleanup Cursor
	CLOSE curPromoList
	DEALLOCATE curPromoList

-- send result back
set @SuppressDIP=@theResult


GO
GRANT EXECUTE ON [Concierge_SuppressDIP_Wrapper] TO ExecuteOnlyRole

GO
