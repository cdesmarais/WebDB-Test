if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Marketing_Report_No_Demo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Marketing_Report_No_Demo]
GO



create procedure dbo.Marketing_Report_No_Demo

as

set transaction isolation level read uncommitted
SET NOCOUNT on
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
inner join Restaurant r
on         Reservation.RID  = r.RID 
inner join Neighborhood 
on         r.neighborhoodid = Neighborhood.neighborhoodid 
inner join MetroArea 
on         Neighborhood.metroareaid <> 1 
and        Reservation.RStateID IN (1,2,5,6,7)
group by   Customer.CustID
          ,Customer.FName
          ,Customer.LName
          ,Customer.email
          ,Customer.createdate
          ,Customer.metroareaid
          ,cast(Customer.SendAnnouncements as Int)
          ,Customer.points
)
UNIon

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
inner join Restaurant r
on         Reservation.RID  = r.RID 
inner join Neighborhood 
on         r.neighborhoodid = Neighborhood.neighborhoodid 
inner join MetroArea 
on         Neighborhood.metroareaid <> 1 
where      Caller.PositionID = 3
and        Reservation.RStateID IN (1,2,5,6,7)
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

GRANT EXECUTE ON [marketing_report_no_demo] TO ExecuteOnlyRole

GO
