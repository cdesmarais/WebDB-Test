IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetRealTimeResoData]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetRealTimeResoData]
GO

CREATE PROCEDURE [dbo].[GetRealTimeResoData] (@startResID int) 
AS
BEGIN
set transaction isolation level read uncommitted

declare @maxDate DateTime
if (@startResID is null)
begin
	select @startResID = max(resid), @maxDate = min(datemade) from Reservation 
	where shiftdate between getdate() - 30 and getdate() - 10
end
else
begin
	select @maxDate = (min(datemade) - 5) from reservation where ResID between @startResID and @startResID + 1000
end

select		res.resid,
			dateadd(hh, 8 - (case when DSTType is not null then 1 else 0 end),datemade) datemadeutc,
			(ShiftDate + 2 + ResTime) shiftdatetime,
			partysize,
			(case when res.IncentiveID is not null then 'POP'
				when a.RestRefIDFirstIn = res.RID 
				and isnull(ref.ExcludeFromBillingTypeRule, 1) = 1 then 'restref'
				else 'standard' end) billingtype, 
			r.rid, 
			replace(rname, '"','\"') [restaurantname], 
			latitude, 
			longitude, 
			p.partnerid, 
			replace(partnername, '"','\"') [partnername]
from		Reservation res
left join	RestaurantVW r
on			res.RID = r.RID
left join	Partner p
on			res.PartnerID = p.PartnerID
left join	DSTSchedule d
on			d.dsttype = 1 -- north america
and			res.datemade between DSTStartDT and DSTEndDT
left join	Attribution_FirstInLastIn a
on			res.ResID = a.ResID
left join	Referrer ref
on			ref.ReferrerID = a.ReferrerIDFirstIn
where		res.ResID > @startResID
and			res.ResID <= (@startResID + 100000) -- Never retrieve more than 100k records. 
and			ShiftDate >= @maxDate -- optimization to restrict query to a specific partition
order by	res.ResID

END

GO

GRANT EXECUTE ON [GetRealTimeResoData] TO ExecuteOnlyRole

GO
