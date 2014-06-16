if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNHotellResoReportDetail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNHotellResoReportDetail]
GO


CREATE PROCEDURE dbo.DNHotellResoReportDetail
(
	@StartDT DateTime,
	@EndDT DateTime,
	@CompanyID int,
	@CallerList varchar(8000), --[EV: List of Int IDs]
	@RIDList varchar(8000) --[EV: List of Int IDs]
)
WITH RECOMPILE

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--*****************************
--** Retrireves history using RestaurantVW
--** Histroy will only include restaurants in a language supported by the domain / website of the caller
--*****************************
select		res.rid,
			r.Rname,
			ShiftDate + 2 + ResTime ShiftDT,
			(case	when RStateID in (1) then 'Pending' 
					when RStateID in (2,5,6,7) then 'Seated' 
					when RStateID in (3,8,9) then 'Cancellation' 
					when RStateID in (4, 10) then 'No Show' end) Status,
			(case	when RStateID in (2,5,6,7) then 1
					when RStateID in (3,8,9) then 2 
					when RStateID in (4, 10) then 3 end) StatusOrder,				
			Isnull(seatedsize, partysize) PartySize,
			IsNull(cc.FName, 'Unknown') + ' ' + IsNull(cc.LName, '') GuestFullName,
			cc.LName as GuestLastName,
			cc.FName as GuestFirstName,
			cc.SLName as GuestSLastName,
			cc.SFName as GuestSFirstName
from (
	--****************************
	--** Use a subquery to improve perforamnce with Partitioned Reso Table
	--** NOTE: Query would benifit from an index on ComapnyID and Shiftdate
	--****************************
	select		callerid, 
				custid,
				rid, 
				rstateid, 
				seatedsize, 
				partysize,
				ShiftDate,
				ResTime
	from		Reservation res
	left join	(select id from fIDStrToTab(@CallerList, ',')) cl
	on			res.callerid = cl.id
	left join	(select id from fIDStrToTab(@RIDList, ',')) rl
	on			res.rid = rl.id	
	where		shiftdate >= @startDT and shiftdate < @EndDT + 1
	and			res.CompanyID = @CompanyID
	and			RStateID in (1,2,3,4,5,6,7,8,9,10)
	and			(@CallerList is null or cl.id is not null)  --** If caller list provided then filter based on it
	and			(@RIDList is null or rl.id is not null) --** If RID list provided then filter based on it
) res
INNER JOIN	RestaurantVW r
ON			r.RID = res.RID
inner join	Caller c
on			c.callerid = res.callerid
left join	CallerCustomer cc
on			cc.custid = res.custid
order by	Rname, StatusOrder, ShiftDate
GO


GRANT EXECUTE ON [DNHotellResoReportDetail] TO ExecuteOnlyRole

GO
