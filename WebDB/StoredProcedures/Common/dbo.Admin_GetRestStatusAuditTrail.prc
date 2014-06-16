if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetRestStatusAuditTrail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetRestStatusAuditTrail]
GO




CREATE PROCEDURE dbo.Admin_GetRestStatusAuditTrail
(
	@RID int	
)
  
As

set transaction isolation level read uncommitted
-- integrate backsoon information as well into this output

SELECT DISTINCT * FROM
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
order by statuschangedatets desc


/* Test Case
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

GRANT EXECUTE ON [Admin_GetRestStatusAuditTrail] TO ExecuteOnlyRole

GO
