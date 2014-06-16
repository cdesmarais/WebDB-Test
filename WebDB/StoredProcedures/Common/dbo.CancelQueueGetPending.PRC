if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CancelQueueGetPending]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CancelQueueGetPending]
GO

CREATE PROCEDURE dbo.CancelQueueGetPending
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @curDT DateTime


--*******************************
--** Expire CancelQueue Items that have already passed
--*******************************
set @curDT = getdate()

--*******************************
-- De-Activate Resos that are in the cancel queue and are past due
--*******************************
update		CancelQueue 
set			active = 0
from		CancelQueue cq
left join	reservation re
on			re.ResID = cq.resID 
and			cq.resid is not null
inner join	Restaurant r 
on			isnull(cq.rid, re.rid) = r.rid
inner join	neighborhood n
on			r.neighborhoodid = n.neighborhoodid
inner join	metroarea m 
on			n.metroareaid = m.metroareaid
inner join	timezoneVW tz 
on			m.tzid = tz.tzid
where		cq.active = 1
and			Dateadd(mi, LocalToServerOffsetMi, isnull(cq.ShiftDT, re.shiftdate + re.restime + 2)) < @curDT -- Time has passed

--*******************************
-- De-Activate Resos that are in the cancel queue and shouldn't be
-- Have a valid reso in the reservation table
--*******************************
update		CancelQueue 
set			active = 0, resid = r.resid
from		cancelqueue c
inner join	reservation r
on			r.rid = c.rid 
and			r.confnumber = c.confnumber
where		c.active = 1 
and			c.resid is null


--*******************************
--** Retrieve Open Items in the Queue
--*******************************
select cq.*,
		dbo.fFormatPhone(r.Phone, cn.countryCode) phone,
		dbo.fFormatPhone(custUnformatedPhone, cn.countryCode) custPhone,
		r.rname
from 
(
	select 		CancelQueueID,
				c.CreateDT,
				c.ResID,
				isnull(c.RID, r.RID) RID,
				isnull(c.ConfNumber, r.ConfNumber) ConfNumber,
				isnull(c.ShiftDT, r.shiftdate + r.restime + 2) ShiftDT,
				isnull(c.PartySize, r.PartySize) PartySize,
				isnull(contactphone, 'unknown') custUnformatedPhone,
				(case when r.resid is null then 'unknown'
					when r.callerid is not null then (select isnull(Fname,'') + ' ' + isnull(Lname,'') from callercustomer cl where cl.custid = r.custid)
					else (select isnull(Fname,'') + ' ' + isnull(Lname,'') from customer cu where cu.custid = r.custid) 
				end) custName,
				MailSent,
				active
	from		CancelQueue c
	left join	reservation r
	on			r.ResID = c.resID 
	and			c.resid is not null
	where		active = 1
	and			datediff(mi, c.createdt, @curDT) > 5 -- Wait five minute before attempting to cancel in the off chance the reso may get entered in our books
) cq
inner join	RestaurantVW r 
on			cq.rid = r.rid
INNER JOIN	Country cn 
ON			cn.countryID = r.country
order by	cq.RID


GO

GRANT EXECUTE ON [CancelQueueGetPending] TO ExecuteOnlyRole

GO
