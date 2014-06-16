GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[marketing_report_orig]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[marketing_report_orig]
GO





create procedure dbo.marketing_report_orig

as

set transaction isolation level read uncommitted
SET NOCOUNT ON
(
select
           Customer.CustID                    as UserID
          ,Customer.FName
          ,Customer.LName
          ,case 
             when left(Customer.email,6) = '111axp'
             then right(Customer.email,len(Customer.email)-6)
               else
             Customer.email
           end                                                        as email
          ,Customer.createdate
          ,Customer.metroareaid
          ,isNull(count(Reservation.ResID),0)  as ResoCount
          ,max(Reservation.DateMade) as LastResoDate
          ,cast(Customer.SendAnnouncements as Int) as OptInStatus
          ,Customer.points
          ,'N'                                                        as IsAdmin
from       Customer
left join  Reservation 
on         Reservation.CustID  = Customer.CustID
group by   Customer.CustID
          ,Customer.FName
          ,Customer.LName
          ,Customer.email
          ,Customer.createdate
          ,Customer.metroareaid
          ,cast(Customer.SendAnnouncements as Int)
          ,Customer.points
)
UNION

(select    Caller.CallerID                            as UserID
          ,Caller.FName
          ,Caller.LName
          ,case 
             when left(Caller.email,6) = '111axp'
             then right(Caller.email,len(Caller.email)-6)
               else
             Caller.email
           end
          ,Caller.CreateDate
          ,Caller.metroareaid
          ,isNull(count(Reservation.ResID),0) as ResoCount
          ,max(Reservation.DateMade)                  as LastResoDate
          ,cast(Caller.SendAnnouncements as Int)       as OptInStatus
          ,Caller.points
          ,'Y'                                                       as IsAdmin
from       Caller
left join  Reservation 
on         Reservation.CallerID    = Caller.CallerID 
where      Caller.PositionID = 3
group by   Caller.CallerID
          ,Caller.FName
          ,Caller.LName
          ,Caller.email
          ,Caller.CreateDate
          ,Caller.metroareaid
          ,cast(Caller.SendAnnouncements as Int)
          ,Caller.points

)






GO


GRANT EXECUTE ON [marketing_report_orig] TO ExecuteOnlyRole

GO
