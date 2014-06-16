if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobIdentifyFraudSuspects]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobIdentifyFraudSuspects]
go

create procedure dbo.JobIdentifyFraudSuspects 
as 
begin

	/*	This proc is called as part of a DTS package.  
	*/

	set transaction isolation level read uncommitted
	set nocount on 

	declare  @shiftdate datetime
			,@FF_LookBackDays int
			,@FF_AssumedDipRate float
			,@FF_AssumedDipPercent float
			,@FF_AssumedPercent float
			,@FF_AssumedDipTotal int
			,@FF_AssumedTotal int
			,@FF_RestTargetASPercent	float
			,@FF_RestTargetDipPercent	float
			,@FF_RestTargetThreshhold	float
			,@infinity	float
			
	set @infinity = 100.0			

	-- Get configured thresholds
	-- Note FF stands for Fraud Flagging
	select @FF_LookBackDays =		ValueInt from ValueLookup where LType = 'WEBSERVER' and LKey = 'FF_LookbackDays'
	select @FF_AssumedDipTotal =	ValueInt from ValueLookup where LType = 'WEBSERVER' and LKey = 'FF_AssumedDipTotal'
	select @FF_AssumedTotal =		ValueInt from ValueLookup where LType = 'WEBSERVER' and LKey = 'FF_AssumedTotal'
	

	-- These are stored in db as ints, cast to float and divide by 100
	select @FF_AssumedDipRate		=	cast(ValueInt as float)/100 from ValueLookup where LType = 'WEBSERVER' and LKey = 'FF_AssumedDipRate'
	select @FF_AssumedDipPercent	=	cast(ValueInt as float)/100 from ValueLookup where LType = 'WEBSERVER' and LKey = 'FF_AssumedDipPercent'
	select @FF_AssumedPercent		=	cast(ValueInt as float)/100 from ValueLookup where LType = 'WEBSERVER' and LKey = 'FF_AssumedPercent'
	select @FF_RestTargetASPercent	=	cast(ValueInt as float)/100 from ValueLookup where LType = 'WEBSERVER' and LKey = 'FF_RestTargetASPercent'
	select @FF_RestTargetDipPercent =	cast(ValueInt as float)/100 from ValueLookup where LType = 'WEBSERVER' and LKey = 'FF_RestTargetDipPercent'
	select @FF_RestTargetThreshhold =	cast(ValueInt as float)/100 from ValueLookup where LType = 'WEBSERVER' and LKey = 'FF_RestTargetThreshhold'

	-- Determine the date that we will use as the starting point for considering reservations
	set @shiftdate = getdate() - @FF_LookBackDays

	--Create a temp table for all resos after the cutoff date, we will use this instead of the reservation view.
	CREATE TABLE #TempReso(
	ResID int NOT NULL,
	ShiftDate datetime NOT NULL,
	RStateID int NOT NULL,
	CallerID int NULL,
	CustID int NOT NULL,
	RID int NOT NULL,
	IncentiveID int NULL,
	ResPoints int NOT NULL) 

	INSERT INTO #TempReso
	SELECT ResID,
		ShiftDate,
		RStateID,
		CallerID,
		CustID,
		RID,
		IncentiveID,
		ResPoints
	FROM Reservation
	where ShiftDate>=@shiftdate

	-- Find users who's probation period is over and update their fraud status
	update	SuspectedFraudulentAccounts
	set		 ProbationStartDate = null
			,FraudStatusID = 4			-- Cleared probation
			,LastChangedBy		= N'System'
	where	ProbationStartDate <= @shiftdate
	and		FraudStatusID = 3


	create table #TargetRestaurants
	(
		rid int primary key
	)
	
	-- create a temporary table of restaurants that meet out target criteria
	insert #TargetRestaurants
	select rid 
	from
	(
		select		r.rid
					,sum( case	when r.RStateID in (2,5) 
									or (r.RStateID = 4 and ans.resid is not null) then 1 else 0 end )	Seated
					,sum( case	when r.RStateID = 5 
									or (r.RStateID = 4 and ans.resid is not null) 
								then 1 else 0 end )	AssumedSeatedNoShow
					,sum( case	when r.incentiveID is not null then 1 else 0 end )	Dip
		from		#TempReso r
		inner join	Restaurant rest
		on			rest.RID = r.RID 
		left join	ResoErbASsumedNoShow ans
		on			r.resid = ans.resid
		where		r.shiftdate > @shiftdate
		and			rest.RestaurantType <> 'A' 
		group by	r.rid
	) a 
	where 
		case when a.seated = 0 then 0 else cast(a.AssumedSeatedNoShow as float)/ cast(a.Seated as float) end > @FF_RestTargetASPercent
		and 
		case when a.seated = 0 then 0 else cast(a.Dip as float) / cast( a.seated as float) end > @FF_RestTargetDipPercent

	-- Select users who fail our tests 
	select		 case when UserID > 0 then UserID else null end CustID
				,case when UserID < 0 then -1 * UserID else null end CallerID
				,UserID
	into #TempSuspects
	from (
		-- Inner select to simplify expressions in where clause
		select	 UserID
				,u.PositionID
				,cast(TotalSeated as float) TotalSeated
				,cast(TotalAssumedSeatedNoShowDip as float) TotalAssumedSeatedNoShowDip
				,cast(TotalTargetRestaurants as float) TotalTargetRestaurants
				,cast(TotalAssumedSeatedNoShow as float) TotalAssumedSeatedNoShow
		from
		(
			-- Get some user totals
			select  	isnull(-1*r.callerid, r.custid)		UserID
						,sum( case when 
							r.rstateid in (2,5) 
							or (r.rstateid = 4 
								and ans.resid is not null)
							then 1 
							else 0 end)					TotalSeated
						,sum(case when 
							r.Incentiveid is not null				-- Dip
							and (r.rstateid =5						-- Assumed Seated
									or ( r.rstateid = 4				-- assumed no show
									and ans.resid is not null ))
							then 1 
							else 0 end)					TotalAssumedSeatedNoShowDip
						,sum(case when 
							r.respoints != 0
							and (r.rstateid =5						-- Assumed Seated
									or ( r.rstateid = 4				-- assumed no show
									and ans.resid is not null ))
							then 1 
							else 0 end)					TotalAssumedSeatedNoShow
						,sum( case when 
							tr.rid is not null and 
							( r.rstateid in (2,5) 
								or (r.rstateid = 4 
								and ans.resid is not null))
							then 1 
							else 0 end)					TotalTargetRestaurants
			from		#TempReso r
			inner join	Restaurant rest
			on			rest.RID = r.RID 
			left join	#TargetRestaurants tr
			on			r.rid = tr.rid
			left join	SuspectedFraudulentAccounts f	
			on			isnull(-1*f.callerid, f.custid) = isnull(-1*r.callerid, r.custid)
			and			f.FraudStatusID = 3
			left join	ResoErbAssumedNoShow ans
			on			ans.resid = r.resid
			where		r.shiftdate > @shiftdate
			and			r.shiftdate > isnull(f.ProbationStartDate, @shiftdate)	-- note this needs to be on it's own row to use index on line above first
			and			rest.RestaurantType <> 'A' 
			group by	isnull(-1*r.callerid, r.custid)						
		) a
		inner join UserWebVw u
		on u.UserWebID = a.UserID
		
		-- limit here first before join for performance improvement (16 minutes -> 45 seconds)
		where TotalAssumedSeatedNoShowDip >= @FF_AssumedDipTotal or TotalAssumedSeatedNoShow >= @FF_AssumedTotal 
	) b
	where	( 	TotalAssumedSeatedNoShowDip >= @FF_AssumedDipTotal
				and 
				(	case when b.TotalSeated = 0 then @infinity else b.TotalAssumedSeatedNoShowDip /b.TotalSeated end > @FF_AssumedDipPercent 
					or
					case when b.TotalSeated = 0 then @infinity else b.TotalTargetRestaurants/b.TotalSeated end > @FF_RestTargetThreshhold
				)
			)						
			or
			(	(b.PositionID is null or b.PositionID != 2) -- exclude concierges
				and 
				TotalAssumedSeatedNoShow >=@FF_AssumedTotal
				and 
				case when b.TotalSeated = 0 then @infinity else b.TotalAssumedSeatedNoShow/b.TotalSeated end >= @FF_AssumedPercent
			)

	-- insert newly identified suspects
	insert		SuspectedFraudulentAccounts (
				 CustID
				,CallerID
				,Cleared
				,FraudStatusID
				,ProbationStartDate
				,LastChangedBy )
	select		 t.Custid
				,t.CallerID
				,0
				,2				-- Assumed no show
				,null
				,N'System'
	from		#TempSuspects t
	left join	SuspectedFraudulentAccounts s
	on			t.UserID = s.UserID
	where		s.UserID is null

	-- reflag users who were on probation but new activity failed test
	update		SuspectedFraudulentAccounts
	set			 FraudStatusID		= 2
				,ProbationStartDate = null
				,LastChangedBy		= N'System'
	from		#TempSuspects t
	inner join	SuspectedFraudulentAccounts s
	on			t.UserID = s.UserID
	where		s.FraudStatusID not in (2,7)	-- don't reflag users who are white-listed

	if object_id ('tempdb..#TargetRestaurants') > 0   
		drop table #TargetRestaurants

	if object_id ('tempdb..#TempSuspects') > 0   
		drop table #TempSuspects

end
GO

GRANT EXECUTE ON [JobIdentifyFraudSuspects] TO ExecuteOnlyRole 
GO
