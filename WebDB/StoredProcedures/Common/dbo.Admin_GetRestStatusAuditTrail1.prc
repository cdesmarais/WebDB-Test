
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetRestStatusAuditTrail1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetRestStatusAuditTrail1]
GO 

create procedure [dbo].[Admin_GetRestStatusAuditTrail1]  
(  
	@RID int  
	,@PagingStartDTPST datetime = null
	,@PagingEndDTPST datetime = null
	,@CurrPageStartDTPST datetime = null
	,@CurrPageEndDTPST datetime = null
	,@PageSize int
	,@IsForwardPage bit  
)  
as 
declare @MonthsForRestStatusAudit int
declare @CurrentDTPST datetime
declare @ReserveNow varchar(15)
declare @BackSoon varchar(10)

set @ReserveNow = 'Reserve Now'
set @BackSoon = 'Back Soon'

-- set current datetime
set @CurrentDTPST =  convert(varchar(20),getdate(),120)

-- looking for last 3 months data only
set @MonthsForRestStatusAudit = -3

-- set all date parameter with @CurrentDTPST if parameter is null
-- for first page all date parameter will remain as null
set @PagingStartDTPST  =  coalesce(@PagingStartDTPST,@CurrentDTPST)
set @CurrPageStartDTPST = coalesce(@CurrPageStartDTPST,@CurrentDTPST)
set @CurrPageEndDTPST = coalesce(@CurrPageEndDTPST,@CurrentDTPST)

-- Set Paging end date as before 3 month to current date
set @PagingEndDTPST = coalesce(@PagingEndDTPST,dateadd(m,@MonthsForRestStatusAudit,@CurrentDTPST))


declare @rows int
declare @tmpRestStatusLog table  
(  
	id int identity(1,1),
	RID int not null  
	,StatusChangeDTPST datetime not null  
	,UserID varchar(100) not null	
	,theNewStatus varchar(100) not null
)


set transaction isolation level read uncommitted  
insert @tmpRestStatusLog
	SELECT DISTINCT * 
	FROM
	(
		(
			select	l.RID,
					CONVERT(varchar(20), 
					l.StatusChangeDateTS, 120) as statuschangedatets,
					l.UserID,
			case when l.newstatus=1 then 
				--Only treat restaurant as "Reserve Now" if the current status is Active (ReststateID = 1)
				-- and the Heartbeat was present during at the time the status changed
				-- If restaurant is active and Heartbeat not presetn then "Backsoon"
				case when (	
							select isonline 
							from reststatuslog 
							where statuschangedate 
								=(select max(statuschangedate) 
									from reststatuslog 
									where statuschangedate <= l.statuschangedatets
									and rid=@RID
								) 
							and rid=@RID
							) = 1 then 'Reserve Now' 
				else 'Back Soon'
				end
			else (	select rstate 
					from restaurantstate 
					where reststateid=l.newstatus
			) 
			end	as theNewStatus 
			from	RestStatusTrackLog l 
			where	l.rid=@RID  
			and		statuschangedatets > dateadd(m,-3,getdate())
	) 
	UNION all
	(
		-- go back only 90 days for backsoon data..
		-- JH 7/2007
		select	rid, 
				CONVERT(varchar(20), statuschangedate, 120)  as statuschangedatets,
				'Website 4.0(Auto)' as UserID,
				(case when	(
							select newstatus
							from RestStatusTrackLog l 
							where statuschangedatets = (
								select max(statuschangedatets)
								from RestStatusTrackLog l 
								where	l.statuschangedatets <= bs.statuschangedate
								and		l.rid = bs.rid 
							)
							and		bs.rid = l.rid 
						) = 1
						--Only treat restaurant as "Reserve Now" if the current status is Active (ReststateID = 1)
						-- and the Heartbeat was present during at the time the status changed
						-- If restaurant is active and Heartbeat not presetn then "Backsoon"
						then (case
								when isonline=0 then 'Back Soon' 
								else 'Reserve Now' 
								end
							 )
						else 'Suppress'   -- suppress and IsReachable toggle if the restaurant was not online at the time of the toggle
				end) as theNewStatus 
		from	reststatuslog bs
		where	bs.rid=@RID 
		and		statuschangedate > dateadd(m,-3,getdate())
	)
	) AS tab
	where 		theNewStatus != 'Suppress'
	and
	(
							(@IsForwardPage = 1 
							and			StatusChangeDateTS > @PagingEndDTPST 
							and 		StatusChangeDateTS  < @CurrPageEndDTPST   
				)
				or			(@IsForwardPage = 0 
							and StatusChangeDateTS < @PagingStartDTPST 
							and StatusChangeDateTS	> @CurrPageStartDTPST   
				)
	)
	order by StatusChangeDateTS desc

set @rows = @@Rowcount


--********************************************
--** Get the Min and Max dates of the current page
--********************************************
select
	@CurrPageStartDTPST=max(StatusChangeDTPST)
	,@CurrPageEndDTPST=min(StatusChangeDTPST)
from 
	@tmpRestStatusLog 
where	(@IsForwardPage = 1 and id between 1 and @PageSize )
or		(@IsForwardPage = 0 and id between @rows - @PageSize and @rows)


--************************************
--** Only return the records within the PageSize limit
--** If Forward = 1 take the first set of records
--** If Forward = 0 take the tail of teh records
--************************************
select
	RID 
	,convert(varchar(20), StatusChangeDTPST, 120) as StatusChangeDTPST
	-- Convert StatusChangeDTPST in to JST
	,convert(varchar(20), dbo.fTimeConvert (StatusChangeDTPST,4,27), 120) as StatusChangeDTJST
	,UserID
	,theNewStatus 
	-- This coulum is used to only for display records in desc order here milisecond is aslo considerd in timestamp.
	,convert(varchar(24), StatusChangeDTPST, 121) as StatusChangeDT
from	@tmpRestStatusLog
where	(@IsForwardPage = 1 and id between 1 and @PageSize )
or		(@IsForwardPage = 0 and id between @rows - @PageSize and @rows)
order by StatusChangeDTPST desc

-- select current page start & end date,Paging start & end date
select 
	@PagingStartDTPST as PagingStartDTPST
	,@PagingEndDTPST as PagingEndDTPST
	,@CurrPageStartDTPST as CurrPageStartDTPST  
	,@CurrPageEndDTPST as CurrPageEndDTPST




/* Test Case
See: Steps to reproduce TT: 37066
insert into RestStatusTrackLog values (1, '2009-09-01', 'ed', 1) -- Online
insert into reststatuslog values (1, 0, '2009-09-02') -- No Heartbeat
insert into reststatuslog values (1, 1, '2009-09-03') -- Heartbeat
insert into RestStatusTrackLog values (1, '2009-09-04', 'ed', 10) -- OFFLINE
insert into reststatuslog values (1, 0, '2009-09-05') -- No Heartbeat
insert into reststatuslog values (1, 1, '2009-09-06') -- Heartbeat

Expected result:
RID	statuschangedatets	UserID	theNewStatus
1	2009-09-04 00:00:00	ed	Client Grace Period
1	2009-09-03 00:00:00	Website 4.0(Auto)	Reserve Now
1	2009-09-02 00:00:00	Website 4.0(Auto)	Back Soon
1	2009-09-01 00:00:00	ed	Reserve Now

-- No Heartbeat toggles appear after the 4th because restaurant is not active
*/

GO

GRANT EXECUTE ON [Admin_GetRestStatusAuditTrail1] TO ExecuteOnlyRole

GO

