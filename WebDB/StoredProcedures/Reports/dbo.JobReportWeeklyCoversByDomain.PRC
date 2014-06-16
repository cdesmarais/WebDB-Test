
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportWeeklyCoversByDomain]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportWeeklyCoversByDomain]
go



CREATE  PROCEDURE dbo.JobReportWeeklyCoversByDomain (@DomainID int)

as

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @StartDate datetime
declare @EndDate datetime

select @EndDate = MAX(datemade) from reservation
set @StartDate = DATEADD(day, -7, @EndDate)

select		r.RName
			,r.RID
			,m.MetroAreaName
			,isnull([OT Reservations], 0) 'OT Reservations'
			,isnull([OT Covers], 0) 'OT Covers'
			,isnull([RestRef Reservations], 0) 'RestRef Reservations'
			,isnull([RestRef Covers], 0) 'RestRef Covers'
			,isnull([POP Reservations], 0) 'POP Reservations'
			,isnull([POP Covers], 0) 'POP Covers'
			,isnull([Total Reservations], 0) 'Total Reservations'
			,isnull([Total Covers], 0) 'Total Covers'
from		RestaurantVW r
left join	(select		rest.RName
						,reso.RID
						,metro.MetroAreaName
						,sum(case when reso.BillingType = 'OTReso' then 1 else 0 end) 'OT Reservations'
						,sum(case when reso.BillingType = 'OTReso' then billablesize else 0 end) 'OT Covers'
						,sum(case when reso.BillingType = 'RestRefReso' then 1 else 0 end) 'RestRef Reservations'
						,sum(case when reso.BillingType = 'RestRefReso' then billablesize else 0 end) 'RestRef Covers'
						,sum(case when reso.BillingType = 'DIPReso' then 1 else 0 end) 'POP Reservations'
						,sum(case when reso.BillingType = 'DIPReso' then billablesize else 0 end) 'POP Covers'
						,count(1) 'Total Reservations'
						,sum(billablesize) 'Total Covers'
			from		ReservationVW reso
			inner join	NeighborhoodVW neigh
			on			reso.NeighborhoodID = neigh.NeighborhoodID
			inner join  MetroAreaVW metro
			on 			metro.MetroAreaID = neigh.MetroAreaID
			inner join	RestaurantVW rest
			on			reso.RID = rest.RID
			where		reso.shiftdate > dateadd(day, -7, @StartDate)  -- for performance
			and			reso.Datemade >= @StartDate
			and			reso.DateMade < @EndDate
			and			metro.Active = 1 
			and			metro.MetroAreaID <> 1
			and			rest.DomainID = @DomainID
			group by	rest.RName
						,reso.RID
						,metro.MetroAreaName) temp
on			r.RID = temp.RID
inner join	NeighborhoodVW n
on			r.NeighborhoodID = n.NeighborhoodID
inner join  MetroAreaVW m
on 			m.MetroAreaID = n.MetroAreaID
where		m.Active = 1
and			m.MetroAreaID <> 1
and 		r.DomainID = @DomainID
order by	m.MetroAreaName


GO

GRANT EXECUTE ON [JobReportWeeklyCoversByDomain] TO ExecuteOnlyRole

GO