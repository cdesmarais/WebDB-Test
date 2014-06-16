
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReportFinancePoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReportFinancePoints]
GO

CREATE Procedure dbo.ReportFinancePoints
as
begin

create table #ResoPointSummary
(
custid int,
callerid int,
total_reso_activity int,
DIP_Points int,
STD_Points int,
accume_reso_points int,
CalMonthDip int,
CalMonthStd int,
last_reso_activity datetime
)

-- Redempion point summary
create table #RedeemSummary
(
custid int,
callerid int,
total_redemptions int,
pointsredeemed int,
cal_pointsredeemed int
)


create table #PromoUseSummary
(
custid int,
callerid int,
PromoPoints int,
cal_PromoPoints int
)


create table #AdjustSummary
(
custid int,
callerid int,
AdjustmentAmount int,
cal_AdjustmentAmount int
)

create index #PromoUseSummary_Idx on #PromoUseSummary (custid,callerid)
create index #ResoPointSummaryIdx on #ResoPointSummary (custid,callerid)
create index #RedeemSummaryIdx on #RedeemSummary (custid,callerid)
create index #AdjustSummary_Idx on #AdjustSummary (custid,callerid)


declare @LastYear datetime
declare @LastCalMonth datetime
declare @EndDate datetime

set @EndDate  = getdate()
set @EndDate  = Cast(convert(nvarchar,dateadd(day,-(day(@EndDate)-1), @EndDate),101) as datetime)

Select @LastCalMonth = dateadd(m,-1,@EndDate) --get prior month's date from range
Select @LastYear = dateadd(month,-12,@LastCalMonth)


insert into #PromoUseSummary
		select (case when callerid is null then custid else null end) custid, 
				callerid, 
				sum(pu.Points) PromoPoints,

				sum(case when redeemDate >= @LastCalMonth then pu.Points
					else 0 end) cal_PromoPoints
		 from promouse pu
		 inner join Promos p on pu.promoid = p.promoid
		where redeemDate < @EndDate
		and PromoTypeID <> 2
group by (case when callerid is null then custid else null end)
	,callerid


insert into #AdjustSummary
		select (case when callerid is null then custid else null end) custid, 
				callerid, 
				sum(AdjustmentAmount) AdjustmentAmount,

				sum(case when AdjustmentDate >= @LastCalMonth then AdjustmentAmount
					else 0 end) cal_AdjustmentAmount
		 from pointsadjustment g
		where AdjustmentDate < @EndDate
group by (case when callerid is null then custid else null end)
	,callerid

-- ## Insert Into ResoPointSummary
insert into #ResoPointSummary
select  (case when callerid is null then custid else null end) custid, 
	callerid, 
	count(1) total_reso_activity,
	sum(case when rstateid not in (2,5,6,7) then 0
		when ResPoints = 1000 then ResPoints
	     else 0 end) DIP_Points,
	sum(case when rstateid not in (2,5,6,7) then 0
		when ResPoints != 1000 then ResPoints
	     else 0 end) STD_Points,
	sum(case when rstateid in (2,5,6,7) then ResPoints
	     else 0 end) accume_reso_points,
	sum(case when rstateid not in (2,5,6,7) then 0
		when shiftdate >= @LastCalMonth and shiftdate < @EndDate and ResPoints = 1000 then ResPoints
	     else 0 end) CalMonthDip,
	sum(case when rstateid not in (2,5,6,7) then 0
		when shiftdate >= @LastCalMonth and shiftdate < @EndDate and ResPoints != 1000 then ResPoints
	     else 0 end) CalMonthStd,
	max(datemade) last_reso_activity
from reservation r
inner join restaurant rest on r.rid = rest.rid
left join ReferrerRestaurantReservationVW rrr on   r.resid = rrr.resid
where datemade < @EndDate
and rest.neighborhoodID not in (select neighborhoodID from neighborhood where metroareaID = 1)
group by (case when callerid is null then custid else null end), callerid 


insert into #RedeemSummary
select  (case when callerid is null then custid else null end) custid
	,callerid
	,count(1) total_redemptions
	,sum(pointsredeemed) pointsredeemed
	,sum(case when redemptionDate >= @LastCalMonth then pointsredeemed
			else 0 end) cal_pointsredeemed
from giftredemption 
where redemptionDate < @EndDate
group by (case when callerid is null then custid else null end)
	,callerid


--====================================
--Regular User Points
--====================================
declare @Reg_RegOtherPoints nvarchar(30)
declare @Reg_StandardPoints nvarchar(30)
declare @Reg_dipPoints nvarchar(30)
declare @Reg_Cal_RegOtherPoints nvarchar(30)
declare @Reg_Cal_StandardPoints nvarchar(30)
declare @Reg_Cal_dipPoints nvarchar(30)
declare @Reg_PointsRedeemed nvarchar(30)
declare @Reg_AccountsRedeemed nvarchar(30)
declare @Reg_Cal_PointsRedeemed nvarchar(30)
declare @Reg_Cal_PointsAcct nvarchar(30)
declare @Reg_active_points nvarchar(30)
declare @Reg_active_accounts nvarchar(30)
declare @Reg_inactive_points nvarchar(30)
declare @Reg_inactive_accounts nvarchar(30)
declare @Reg_active_points_lt_1000 nvarchar(30)
declare @Reg_active_accounts_lt_1000 nvarchar(30)
declare @Reg_active_points_gt_1000 nvarchar(30)
declare @Reg_active_accounts_gt_1000 nvarchar(30)


		select 
		@Reg_RegOtherPoints = sum(coalesce(PromoPoints,0) + coalesce(AdjustmentAmount,0)	)
		,@Reg_StandardPoints = sum (Std_Points)
		,@Reg_dipPoints = sum(DIP_Points)

		,@Reg_Cal_RegOtherPoints = sum(coalesce(cal_PromoPoints,0)
		      + coalesce(cal_AdjustmentAmount,0))
		,@Reg_Cal_StandardPoints = sum (CalMonthStd)
		, @Reg_Cal_dipPoints = sum(CalMonthDip) 

		, @Reg_PointsRedeemed = sum(pointsredeemed) 
		, @Reg_AccountsRedeemed = count(pointsredeemed) 

		, @Reg_Cal_PointsRedeemed = sum(cal_pointsredeemed) 
		, @Reg_Cal_PointsAcct = sum(case when cal_pointsredeemed > 0 then 1 else 0 end) 

		, @Reg_active_points = sum(case when last_reso_activity > @LastYear then points
		  else 0 end) 
		, @Reg_active_accounts =  sum(case when last_reso_activity > @LastYear then 1
		       else 0 end) 
		, @Reg_inactive_points = sum(case when last_reso_activity > @LastYear then 0
		  else points end) 
		, @Reg_inactive_accounts =  sum(case when last_reso_activity > @LastYear then 0
		       else 1 end) 
		, @Reg_active_points_lt_1000 = sum(case when last_reso_activity > @LastYear and points < 1000 then points
		  else 0 end) 
		, @Reg_active_accounts_lt_1000 =  sum(case when last_reso_activity > @LastYear and points < 1000 then 1
		       else 0 end) 
		, @Reg_active_points_gt_1000 = sum(case when last_reso_activity > @LastYear and points >= 1000 then points
		  else 0 end) 
		, @Reg_active_accounts_gt_1000 =  sum(case when last_reso_activity > @LastYear and points >= 1000 then 1
		       else 0 end) 

		from customer c 
		left outer join #ResoPointSummary r on  r.custId = c.custId
		left outer join #RedeemSummary p on  p.custId = c.custId
		left outer join #AdjustSummary a on  a.custId = c.custId
		left outer join #PromoUseSummary pu on  pu.custId = c.custId
		where c.createdate < @EndDate -- Only operate on customers created before report end date
		and c.consumerType != 8 
		and active = 1
		and partnerid != 13
		-- and Company.AcceptPoints = 1

--====================================
--Concierge User Points
--====================================
declare @Admin_RegOtherPoints nvarchar(30)
declare @Admin_StandardPoints nvarchar(30)
declare @Admin_dipPoints nvarchar(30)
declare @Admin_Cal_RegOtherPoints nvarchar(30)
declare @Admin_Cal_StandardPoints nvarchar(30)
declare @Admin_Cal_dipPoints nvarchar(30)
declare @Admin_PointsRedeemed nvarchar(30)
declare @Admin_AccountsRedeemed nvarchar(30)
declare @Admin_Cal_PointsRedeemed nvarchar(30)
declare @Admin_Cal_PointsAcct nvarchar(30)
declare @Admin_active_points nvarchar(30)
declare @Admin_active_accounts nvarchar(30)
declare @Admin_inactive_points nvarchar(30)
declare @Admin_inactive_accounts nvarchar(30)
declare @Admin_active_points_lt_1000 nvarchar(30)
declare @Admin_active_accounts_lt_1000 nvarchar(30)
declare @Admin_active_points_gt_1000 nvarchar(30)
declare @Admin_active_accounts_gt_1000 nvarchar(30)

		select 
		@Admin_RegOtherPoints = sum(coalesce(PromoPoints,0) + coalesce(AdjustmentAmount,0)	)
		,@Admin_StandardPoints = sum (Std_Points)
		,@Admin_dipPoints = sum(DIP_Points)

		,@Admin_Cal_RegOtherPoints = sum(coalesce(cal_PromoPoints,0)
		      + coalesce(cal_AdjustmentAmount,0))
		,@Admin_Cal_StandardPoints = sum (CalMonthStd)
		, @Admin_Cal_dipPoints = sum(CalMonthDip) 

		, @Admin_PointsRedeemed = sum(pointsredeemed) 
		, @Admin_AccountsRedeemed = count(pointsredeemed) 

		, @Admin_Cal_PointsRedeemed = sum(cal_pointsredeemed) 
		, @Admin_Cal_PointsAcct = sum(case when cal_pointsredeemed > 0 then 1 else 0 end) 

		, @Admin_active_points = sum(case when last_reso_activity > @LastYear then points
		  else 0 end) 
		, @Admin_active_accounts =  sum(case when last_reso_activity > @LastYear then 1
		       else 0 end) 
		, @Admin_inactive_points = sum(case when last_reso_activity > @LastYear then 0
		  else points end) 
		, @Admin_inactive_accounts =  sum(case when last_reso_activity > @LastYear then 0
		       else 1 end) 
		, @Admin_active_points_lt_1000 = sum(case when last_reso_activity > @LastYear and points < 1000 then points
		  else 0 end) 
		, @Admin_active_accounts_lt_1000 =  sum(case when last_reso_activity > @LastYear and points < 1000 then 1
		       else 0 end) 
		, @Admin_active_points_gt_1000 = sum(case when last_reso_activity > @LastYear and points >= 1000 then points
		  else 0 end) 
		, @Admin_active_accounts_gt_1000 =  sum(case when last_reso_activity > @LastYear and points >= 1000 then 1
		       else 0 end) 

		from caller c 
		left outer join #ResoPointSummary r on  r.callerid = c.callerid
		left outer join #RedeemSummary p on  p.callerid = c.callerid
		left outer join #AdjustSummary a on  a.callerid = c.callerid
		left outer join #PromoUseSummary pu on  pu.callerid = c.callerid
		where c.createdate < @EndDate -- Only operate on customers created before report end date
		and not exists (select cy.companyid from company cy where cy.companyid = c.companyid and acceptspoints = 0)
		--and active = 1
		and partnerid != 13
		-- and Company.AcceptPoints = 1

--*****************************
--**Construct Email
--*****************************
declare @mail_body nvarchar(4000)
declare @nl as nvarchar(10)
set @nl = CHAR(13) + CHAR(10)
declare @dl as nvarchar(10)
set @dl = ', '

declare @RegTotal int
declare @AdminTotal int

set @mail_body = ''
set @mail_body = @mail_body + @nl + 'Points Issued Current Month:(Regular User, Admin / Concierge)'
set @mail_body = @mail_body + @nl + 'Registration & Other: ' + @Reg_Cal_RegOtherPoints + @dl + @Admin_Cal_RegOtherPoints
set @mail_body = @mail_body + @nl + 'Standard Reso: ' + @Reg_Cal_StandardPoints + @dl + @Admin_Cal_StandardPoints
set @mail_body = @mail_body + @nl + 'DIP: ' + @Reg_Cal_dipPoints + @dl + @Admin_Cal_dipPoints 

set @RegTotal = cast(@Reg_Cal_RegOtherPoints as int) + cast(@Reg_Cal_StandardPoints as int) + cast(@Reg_Cal_dipPoints as int)
set @AdminTotal = cast(@Admin_Cal_RegOtherPoints as int) + cast(@Admin_Cal_StandardPoints as int) + cast(@Admin_Cal_dipPoints as int)
set @mail_body = @mail_body + @nl + 'Total: ' + cast(@RegTotal as nvarchar(30)) + @dl + cast(@AdminTotal as nvarchar(30)) 

set @mail_body = @mail_body + @nl
set @mail_body = @mail_body + @nl + 'Points Redeemed Current Month:(Regular User, Admin / Concierge)'
set @mail_body = @mail_body + @nl + '$ Points: ' + @Reg_Cal_PointsRedeemed + @dl + @Admin_Cal_PointsRedeemed
set @mail_body = @mail_body + @nl + '# Accts: ' + @Reg_Cal_PointsAcct + @dl + @Admin_Cal_PointsAcct



set @mail_body = @mail_body + @nl + @nl + @nl
set @mail_body = @mail_body + @nl + 'Points Issued*:(Regular User, Admin / Concierge)'
set @mail_body = @mail_body + @nl + 'Registration & Other: ' + @Reg_RegOtherPoints + @dl + @Admin_RegOtherPoints
set @mail_body = @mail_body + @nl + 'Standard Reso: ' + @Reg_StandardPoints + @dl + @Admin_StandardPoints
set @mail_body = @mail_body + @nl + 'DIP: ' + @Reg_dipPoints + @dl + @Admin_dipPoints 

set @RegTotal = cast(@Reg_RegOtherPoints as int) + cast(@Reg_StandardPoints as int) + cast(@Reg_dipPoints as int)
set @AdminTotal = cast(@Admin_RegOtherPoints as int) + cast(@Admin_StandardPoints as int) + cast(@Admin_dipPoints as int)
set @mail_body = @mail_body + @nl + 'Total: ' + cast(@RegTotal as nvarchar(30)) + @dl + cast(@AdminTotal as nvarchar(30)) 

set @mail_body = @mail_body + @nl 
set @mail_body = @mail_body + @nl + 'Points Redeemed:(Regular User, Admin / Concierge)'
set @mail_body = @mail_body + @nl + '$ Points: ' + @Reg_PointsRedeemed + @dl + @Admin_PointsRedeemed
set @mail_body = @mail_body + @nl + '# Accts: ' + @Reg_AccountsRedeemed + @dl + @Admin_AccountsRedeemed

set @mail_body = @mail_body + @nl 
set @mail_body = @mail_body + @nl + 'Points Unredeemed'
set @mail_body = @mail_body + @nl + 'Inactive Accounts** :(Regular User, Admin / Concierge)'
set @mail_body = @mail_body + @nl + '$ Points: ' + @Reg_inactive_points + @dl + @Admin_inactive_points
set @mail_body = @mail_body + @nl + '# Accts: ' + @Reg_inactive_accounts + @dl + @Admin_inactive_accounts

set @mail_body = @mail_body + @nl 
set @mail_body = @mail_body + @nl + 'Points Unredeemed - Active Accts'
set @mail_body = @mail_body + @nl + 'Active Accounts*** :(Regular User, Admin / Concierge)'
set @mail_body = @mail_body + @nl + '$ Points: ' + @Reg_active_points + @dl + @Admin_active_points
set @mail_body = @mail_body + @nl + '# Accts: ' + @Reg_active_accounts + @dl + @Admin_active_accounts

set @mail_body = @mail_body + @nl 
set @mail_body = @mail_body + @nl + 'Points Unredeemed - Active Accts'
set @mail_body = @mail_body + @nl + '<1000 Point Balance:(Regular User, Admin / Concierge)'
set @mail_body = @mail_body + @nl + '$ Points: ' + @Reg_active_points_lt_1000 + @dl + @Admin_active_points_lt_1000
set @mail_body = @mail_body + @nl + '# Accts: ' + @Reg_active_accounts_lt_1000 + @dl + @Admin_active_accounts_lt_1000

set @mail_body = @mail_body + @nl 
set @mail_body = @mail_body + @nl + '>=1000 Point Balance:(Regular User, Admin / Concierge)'
set @mail_body = @mail_body + @nl + '$ Points: ' + @Reg_active_points_gt_1000 + @dl + @Admin_active_points_gt_1000
set @mail_body = @mail_body + @nl + '# Accts: ' + @Reg_active_accounts_gt_1000 + @dl + @Admin_active_accounts_gt_1000

declare @mail_subj nvarchar(200)
set @mail_subj = 'Finance Points Report ' + datename(month,@LastCalMonth) + ' ' +  datename(yyyy,@LastCalMonth)

exec master..sp_send_cdosysmail 
 @From = 'reports@opentable.com'
,@To = 'lkim@opentable.com;evaldivia@opentable.com'
,@Subject = @mail_subj
,@Body = @mail_body

end
go

GRANT EXECUTE ON [ReportFinancePoints] TO ExecuteOnlyRole

GO
