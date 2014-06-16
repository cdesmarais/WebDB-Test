GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RefreshResRegRPTSummary]') and OBJECTPROPERTY(id,N'IsProcedure') = 1)
drop procedure [dbo].[RefreshResRegRPTSummary]
GO

CREATE PROCEDURE dbo.RefreshResRegRPTSummary
(
@reportDate datetime = null
)
AS
SET NOCOUNT ON
BEGIN TRANSACTION
set transaction isolation level read uncommitted

declare @curMonth datetime
declare @lastDate datetime -- last summary in table; taht is less than current month; at least 1 month back

set @curMonth  = coalesce(@reportDate,getdate())
set @curMonth  = Cast(convert(nvarchar,dateadd(day,-(day(@curMonth)-1), @curMonth),101) as datetime)


select @lastDate = coalesce(max(reportdate),@curMonth)
from ReservationRPTSummary
where reportDate < @curMonth

-- Delete and reprocess summary
delete ReservationRPTSummary
where reportDate >= @lastDate

Insert into ReservationRPTSummary(RID,MetroAreaID,ReportDate,resos,covers,dining,Business,pleasure,BpNc,tfirst,tsecond,TNc,dis,DisR,nshow)
Select r.RID
	,ma.MetroAreaID
	,Cast(convert(nvarchar,dateadd(day,-(day(shiftdate)-1),shiftdate),101) as datetime) -- month
	,sum(
		case when (r.RStateID in(3,4,8,9,10)) then 0 Else 1 End 
	) as resos
	,sum(
		case when (r.RStateID in(3,4,8,9,10)) then 0 Else (case when coalesce(seatedsize,0) < 1 then PartySize else seatedsize end)  End
	) as covers
	,sum(case when (IncentiveID is not null and (r.RStateID not in(3,4,8,9,10)) ) 
					Then ((case when coalesce(seatedsize,0) < 1 then PartySize else seatedsize end) *7.5) else 0 end) as dining
	,sum(case when (Business = 1 and (r.RStateID not in(3,4,8,9,10)) )
					Then 1 else 0 end) as Business
	,sum(case when (Business = 0 and (r.RStateID not in(3,4,8,9,10)) )
					Then 1 else 0 end) as pleasure
	,sum(case when (Business Is Null and (r.RStateID not in(3,4,8,9,10)) )
					Then 1 else 0 end) as BpNc
	,sum(case when (FirstTime = 1 and (r.RStateID not in(3,4,8,9,10)) )
					Then 1 else 0 end) as tfirst
	,sum(case when (FirstTime = 0 and (r.RStateID not in(3,4,8,9,10)) )
					Then 1 else 0 end) as tsecond
	,sum(case when (FirstTime Is Null and (r.RStateID not in(3,4,8,9,10)) )
					Then 1 else 0 end) as TNc
	,sum(case when (RStateID = 6)Then 1 else 0 end) as dis
	,sum(case when (RStateID = 7)Then 1 else 0 end) as DisR
	,sum(case when (RStateID = 4)Then 1 else 0 end) as nshow
from Reservation r with (nolock)
inner join Restaurant rts on r.RID = rts.RID
inner join Neighborhood n on rts.NeighborhoodID = n.NeighborhoodID
inner join MetroArea ma on n.MetroAreaID = ma.MetroAreaID
Where ma.MetroAreaID <> 1
and shiftdate >= @lastDate
group by r.RID
,	ma.MetroAreaID
,	Cast(convert(nvarchar,dateadd(day,-(day(shiftdate)-1),shiftdate),101) as datetime)


-- Delete and reprocess summary
delete RegistrationRPTSummary
where reportDate >= @lastDate


-- Populate the Current Registration Stats Summary Table
Insert into RegistrationRPTSummary(MetroAreaID,ReportDate,regs,Refs)
    select metroareaid,
        reportDt,
        sum(regs) as regs,
	    sum(Refs)
    from (
        (--- Customer Select
            select metroareaid,
                Cast(convert(nvarchar,dateadd(day,-(day(CreateDate)-1),CreateDate),101) as datetime) reportDt,
                count(Email) as regs,
	            sum(case when (OTRef.RID is not null)Then 1 else 0 end) as Refs
            from Customer OTCust
            left join ReferrerRestaurantRegistration OTRef 
            on OTCust.CustID = OTRef.CustID
            Where CreateDate >= @lastDate
            and MetroAreaID <> 1 
            and OTCust.Email not like '%opentable.com%' -- EV: This seems suspect. Why don't we count opentable customers?
            and OTCust.Email not like '%isAAUser' 
            and OTCust.ConsumerType <> 8
            group by metroareaid, Cast(convert(nvarchar,dateadd(day,-(day(CreateDate)-1),CreateDate),101) as datetime)
         )
        union all
        (--- Caller Select
            select metroareaid,
			(case when CreateDate is null then cast('2001-01-01' as datetime)
                     else  Cast(convert(nvarchar,dateadd(day,-(day(CreateDate)-1),CreateDate),101) as datetime) end) reportDt,
                count(Email) as regs,
	            0 as Refs
            From Caller OTCall
            Where CreateDate >= @lastDate
            and MetroAreaID <> 1 
            and OTCall.PositionID = 3 -- Only take Admin Assistants
            and OTCall.Email not like '%opentable.com%' -- EV: This seems suspect. Why don't we count opentable customers?
            group by metroareaid, (case when CreateDate is null then cast('2001-01-01' as datetime)
                     else  Cast(convert(nvarchar,dateadd(day,-(day(CreateDate)-1),CreateDate),101) as datetime) end)
        )
    ) t
    group by metroareaid,
        reportDt



COMMIT	
go	

GO


GRANT EXECUTE ON [RefreshResRegRPTSummary] TO ExecuteOnlyRole

GO
