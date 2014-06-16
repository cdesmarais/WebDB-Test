if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetDailyResosByUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetDailyResosByUser]
GO

CREATE PROCEDURE dbo.DNGetDailyResosByUser
(
	@WindowStart datetime
)
As

/*
Stored procedure to update a comma separated list of RIDs for users that have had 
reservations booked.

The initial purpose for this return set is to determine an exclusion list
for restaurnts to be recommended to diners.
*/
SET NOCOUNT ON

set transaction isolation level read uncommitted

--The below query seems to be memory intensive
--never return more than a days worth of data
declare @WindowEnd datetime
set @WindowEnd = dateadd(dd,1,@WindowStart)

--When we're ready to add callers to this data, create a UNION
--below this query with a like query joining to the Caller table.
select						c1.CustID,
							null CallerID,
							left(rids, len(rids) -1) RIDS
from (	
	-- Distinct set of users with activity in the window
	select					distinct r1.custid
	from 					Reservation r1
	inner join				Customer c1
	on						r1.CustID = c1.CustID
	where					shiftdate >= @WindowStart
	and						ShiftDate < @WindowEnd
	and						c1.ConsumerType		in	(1,4,5)
) c1
-- For Each User generate comma delimited list of top 10 RIDs
cross apply					(
							select				
												top 10 cast(rid as varchar) + ','
							from				reservation r2
							where				r2.custid = c1.custid
							and					shiftdate >= @WindowStart
							and					ShiftDate < @WindowEnd
							order by			r2.ShiftDate desc, r2.ResTime desc
							for xml path		('')
							) pre_trimmed		(rids)
	
GO

GRANT EXECUTE ON [DNGetDailyResosByUser] TO ExecuteOnlyRole

GO