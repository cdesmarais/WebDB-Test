if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_AddFunnelMetrics]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_AddFunnelMetrics]
GO





CREATE PROCEDURE dbo.DBD_AddFunnelMetrics
(               
  @Month datetime
)
AS

--***This proc is now deprecated.***

-- 5:00
-- All queries should have Partner ID, Referrer ID, and Referring Restaurant ID Channels

--Create temp tables first:
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


create table ##UserCreation
( 
custid int, 
CallerID int, 
PartnerID int,
RefID int,
ReferringRID int,
SendAnnouncements bit, 
ConsumerType int, 
CreateDate datetime, 
ConvertDate datetime
)


create table ##ReservationCreation
( 
custid int, 
CallerID int, 
PartnerID int,
RefID int,
ReferringRID int,
rstateid int, 
DateMade datetime, 
ResDate datetime,
rid int,
resid int
)

print 'Created Tables'

insert into ##ReservationCreation (custid, 
CallerID, PartnerID,rstateid, 
DateMade, ResDate, rid,resid)
Select r.custid, r.callerID, 
PartnerID, 
rstateid, DateMade, (ShiftDate + 2 + ResTime) as  ResDate, r.RID, r.resID
from reservation r
where datediff(mm,DateMade,@Month) = 0
-- 1:12

print 'inserted into ##ReservationCreation'


CREATE  INDEX [TempReservation_NC1] ON [##ReservationCreation]([CustID]) ON [PRIMARY]
CREATE  INDEX [TempReservation_NC2] ON [##ReservationCreation]([CallerID]) ON [PRIMARY]
CREATE  INDEX [TempReservation_NC3] ON [##ReservationCreation]([ResID]) ON [PRIMARY]
CREATE  INDEX [TempReservation_NC4] ON [##ReservationCreation]([DateMade]) ON [PRIMARY]
-- 0:03

print 'Created Indexes'


insert into ##UserCreation (custid, 
CallerID, PartnerID,SendAnnouncements, 
ConsumerType, CreateDate)
Select c.custid, null as callerID, 
PartnerID, 
SendAnnouncements, ConsumerType, CreateDate
from Customer c
where email not like '%isAAUser' and datediff(mm,createDate,@Month) = 0
-- 1:03

print 'inserted New Customers into ##UserCreation'


insert into ##UserCreation (custid, 
CallerID, PartnerID,SendAnnouncements, 
ConsumerType, CreateDate)
Select distinct c.custid, null as callerID, 
c.PartnerID, 
SendAnnouncements, ConsumerType, CreateDate
from Customer c
inner join ##ReservationCreation rc on c.custid = rc.custid
where c.custid not in 
(Select custid from ##UserCreation where custid is not null)
-- 0:05

print 'inserted New Callers into ##UserCreation'

insert into ##UserCreation (custid, 
CallerID, PartnerID,SendAnnouncements, 
ConsumerType, CreateDate)
Select null as custid, ca.callerID, 
PartnerID, 
SendAnnouncements, ConsumerType, CreateDate
from Caller ca
where companyID is null and datediff(mm,createDate,@Month) = 0
-- 0:01

print 'inserted existing customers into ##UserCreation'

insert into ##UserCreation (custid, 
CallerID, PartnerID,SendAnnouncements, 
ConsumerType, CreateDate)
Select null as custid, ca.callerID, 
ca.PartnerID, 
SendAnnouncements, ConsumerType, CreateDate
from Caller ca
inner join ##ReservationCreation rc on ca.callerID = rc.callerID
where ca.callerID not in 
(Select callerID from ##UserCreation where callerID is not null)
 and ca.companyID is null
-- 0:01

print 'inserted existing Callers into ##UserCreation'


update rc
set RefID = referrerID
from ##ReservationCreation rc
inner join ReferrerReservationVW rr on rr.resid = rc.resid
where partnerID = 1
-- 0:04

print 'Added referrerreservation'


update rc
set ReferringRID = rrr.RID
from ##ReservationCreation rc
inner join ReferrerRestaurantReservationVW rrr on rrr.RID = rc.RID and rc.resid = rrr.resid 
where partnerID = 1 and RefID is null
-- 0:03

print 'Added referrerRestaurantreservation'


update uc
set uc.ConvertDate = DateDeactivated
from ##UserCreation uc
inner join Caller ca on uc.CallerID = ca.CallerID and uc.callerID is not null
inner join customer on customer.email like ca.loginname + '%isAAUser'
inner join customersDeactivated on customer.custid = customersDeactivated.custid
where reasonid = 4
-- 0:03

print 'Added ConvertDate'


CREATE  INDEX [TempUserCreation_NC1] ON [##UserCreation]([CustID]) ON [PRIMARY]
CREATE  INDEX [TempUserCreation_NC2] ON [##UserCreation]([CallerID]) ON [PRIMARY]
-- 0:01

print 'Created Indexes'

update uc
set RefID = referrerID
from ##UserCreation uc
inner join referrerregistration rr on rr.custid = uc.custid and uc.custid is not null
where partnerID = 1
-- 0:02

print 'Added RefID'

update uc
set ReferringRID = RID
from ##UserCreation uc
inner join referrerRestaurantregistration rrr on rrr.custid = uc.custid and uc.custid is not null
where partnerID = 1 and RefID is null
-- 0:03

print 'Added ReferringRID'

update uc
set uc.ConvertDate = ctcl.ConvertDate
from ##UserCreation uc
inner join ConsumerTypeConvertLog ctcl on ctcl.custid = uc.custid and uc.custid is not null
and NewConsumerTypeID = 1 and originalConsumerTypeID = 8
-- 0:05

print 'Added ConvertDate'



update uc
set RefID = referrerID
from ##UserCreation uc
inner join referrerregistration rr on rr.callerID = uc.callerID and uc.callerID is not null
where partnerID = 1 
-- 0:00
print 'Added RefID for callers'

update uc
set ReferringRID = RID
from ##UserCreation uc
inner join referrerRestaurantregistration rrr on rrr.callerID = uc.callerID and uc.callerID is not null
where partnerID = 1 and RefID is null 
-- 0:00

print 'Added ReferringRID for callers'



delete from Metrics where MetricDate = @Month
-- 0:00
print 'delete from Metrics'


-- -1- The total number of registrations created during the month.  Exclude normal-to-admin conversions.

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '1' as MetricID, count(distinct coalesce(custid,CallerID)) as MetricValue, @Month as MetricDate, PartnerID, RefID, ReferringRID
from ##UserCreation
where datediff(mm,createdate,@Month) = 0 and consumerType != 8
group by PartnerID, RefID, ReferringRID
-- 0:01

-- -2- The total number of non-Registered user reservations made during the month (includes resos made by anonymous and JIT converts)

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '2' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation uc on rc.custid = uc.custid and rc.custid is not null
where (consumerType = 8 or coalesce(ConvertDate,'1/1/1900') > DateMade)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
union
Select '2' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation uc on rc.CallerID = uc.CallerID and rc.CallerID is not null
where coalesce(ConvertDate,'1/1/1900') > DateMade
group by rc.PartnerID, rc.RefID, rc.ReferringRID
-- 0:03

-- -3- The total number of registrations created during the month.  Exclude normal-to-admin conversions. With Opt-in

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '3' as MetricID, count(distinct coalesce(custid,CallerID)) as MetricValue, @Month as MetricDate, PartnerID, RefID, ReferringRID
from ##UserCreation
where datediff(mm,createdate,@Month) = 0 and consumerType != 8 and sendAnnouncements = 1
group by PartnerID, RefID, ReferringRID
-- 0:01

-- -4- Total reservations made in a month

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '4' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, RefID, ReferringRID
from ##ReservationCreation rc
group by rc.PartnerID, RefID, ReferringRID
-- 0:01

-- -4- Total billable reservations made in a month

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '5' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, RefID, ReferringRID
from ##ReservationCreation rc
where rstateID in (2,5,6,7)
group by rc.PartnerID, RefID, ReferringRID
-- 0:01

-- -5- Total reservations by registered users

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '6' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation uc on rc.custid = uc.custid and rc.custid is not null
where (consumerType != 8)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
union
Select '6' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation uc on rc.CallerID = uc.CallerID and rc.CallerID is not null
group by rc.PartnerID, rc.RefID, rc.ReferringRID
-- 0:06

-- -5- Total Billable reservations by registered users

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '7' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation uc on rc.custid = uc.custid and rc.custid is not null
where (consumerType != 8) and rstateID in (2,5,6,7)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
union
Select '7' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation uc on rc.CallerID = uc.CallerID and rc.CallerID is not null
where rstateID in (2,5,6,7)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
-- 0:06


-- -6- Total reservations by Anonymous users

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '8' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation c on rc.custid = c.custid and rc.custid is not null
where (consumerType = 8)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
-- 0:04


-- -6- Total Billable reservations by Anonymous users

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '9' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation c on rc.custid = c.custid and rc.custid is not null
where (consumerType = 8) and rstateID in (2,5,6,7)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
-- 0:07


-- -7- Total cancelled reservations made in a month

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '10' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, RefID, ReferringRID
from ##ReservationCreation rc
where rstateID in (3,8,9)
group by rc.PartnerID, RefID, ReferringRID
-- 0:01

-- -8- Total cancelled reservations by registered users

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '11' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation uc on rc.custid = uc.custid and rc.custid is not null
where (consumerType != 8) and rstateID in (3,8,9)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
union
Select '11' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation uc on rc.CallerID = uc.CallerID and rc.CallerID is not null
where rstateID in (3,8,9)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
-- 0:02


-- -9- Total cancelled reservations by Anonymous users


--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '12' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation c on rc.custid = c.custid and rc.custid is not null
where (consumerType = 8) and rstateID in (3,8,9)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
-- 0:01

-- -10- Total no-show reservations made in a month

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '13' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, RefID, ReferringRID
from ##ReservationCreation rc
where rstateID in (4,10)
group by rc.PartnerID, RefID, ReferringRID
-- 0:00

-- -11- Total no-show reservations by registered users

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '14' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation uc on rc.custid = uc.custid and rc.custid is not null
where (consumerType != 8) and rstateID in (4,10)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
union
Select '14' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation uc on rc.CallerID = uc.CallerID and rc.CallerID is not null
where (consumerType != 8) and rstateID in (4,10)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
-- 0:01


-- -12- Total no-show reservations by Anonymous users

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '15' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID
from ##ReservationCreation rc
inner join ##UserCreation c on rc.custid = c.custid and rc.custid is not null
where (consumerType = 8) and rstateID in (4,10)
group by rc.PartnerID, rc.RefID, rc.ReferringRID
-- 0:01


-- -13- First Time reservations

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '16' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
union
Select '16' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.CallerID = c.CallerID and rc.CallerID is not null
where datediff(dd,createDate,DateMade) = 0
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
-- 0:03


-- -13- First Time billable reservations

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '17' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (2,5,6,7)
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
union
Select '17' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.CallerID = c.CallerID and rc.CallerID is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (2,5,6,7)
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
-- 0:02


-- -14- First Time Registered (JIT) reservations


--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '18' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0 and consumerType != 8
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
union
Select '18' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.CallerID = c.CallerID and rc.CallerID is not null
where datediff(dd,createDate,DateMade) = 0
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
-- 0:02

-- -14- First Time Registered billable reservations

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '19' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (2,5,6,7) and consumerType != 8
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
union
Select '19' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.CallerID = c.CallerID and rc.CallerID is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (2,5,6,7)
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
-- 0:02


-- -15- First Time Anonymous reservations

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '20' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0 and consumerType = 8
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
-- 0:01

-- -15- First Time Anonymous billable reservations

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '21' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (2,5,6,7) and consumerType = 8
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
-- 0:01

-- -16- First Time cancelled reservations

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '22' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (3,8,9)
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
union
Select '22' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.CallerID = c.CallerID and rc.CallerID is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (3,8,9)
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
-- 0:01

-- -17- First Time registered cancelled reservations

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '23' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (3,8,9) and consumerType != 8
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
union
Select '23' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.CallerID = c.CallerID and rc.CallerID is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (3,8,9)
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
-- 0:01

-- -18- First Time anonymous cancelled reservations

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '24' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (3,8,9) and consumerType = 8
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
-- 0:00

-- -19- First Time no-show reservations

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '25' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (4,10)
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
union
Select '25' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.CallerID = c.CallerID and rc.CallerID is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (4,10)
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
-- 0:01

-- -20- First Time registered no-show reservations

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '26' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (4,10) and consumerType != 8
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
union
Select '26' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.CallerID = c.CallerID and rc.CallerID is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (4,10)
group by rc.PartnerID, rc.RefID, rc.ReferringRID 
-- 0:01

-- -21- First Time anonymous no-show reservations

--Declare @month as DateTime
--Set @Month = '7/1/2005'
insert into Metrics (MetricID,MetricValue,MetricDate,PartnerID, ReferrerID, RestRefID)
Select '27' as MetricID, count(distinct resid) as MetricValue, @Month as MetricDate, rc.PartnerID, rc.RefID, rc.ReferringRID 
from ##ReservationCreation rc
inner join ##UserCreation c on 
rc.custid = c.custid and rc.custid is not null
where datediff(dd,createDate,DateMade) = 0  and rstateID in (4,10) and consumerType = 8
group by rc.PartnerID, rc.RefID, rc.ReferringRID
-- 0:00



Drop table ##UserCreation
Drop table ##ReservationCreation
GO

GRANT EXECUTE ON [DBD_AddFunnelMetrics] TO ExecuteOnlyRole

GO
