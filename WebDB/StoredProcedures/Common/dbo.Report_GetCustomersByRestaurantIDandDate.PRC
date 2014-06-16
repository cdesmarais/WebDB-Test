if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_GetCustomersByRestaurantIDandDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_GetCustomersByRestaurantIDandDate]
GO


CREATE PROCEDURE  dbo.Report_GetCustomersByRestaurantIDandDate

@RestaurantID int,
@Date datetime

AS

set transaction isolation level read uncommitted

Select Customer.FName as First_Name, Customer.LName as Last_Name, Customer.Email 
from Customer 
inner join Reservation 
on Customer.CustID = Reservation.CustID

where Reservation.RID = @RestaurantID 
and datediff(day, Reservation.ShiftDate, @Date) = 0
and Reservation.RStateID = 1

UNION

Select Caller.FName as First_Name, Caller.LName as Last_Name, Caller.Email 
from Caller
inner join Reservation 
on Caller.CallerID = Reservation.CallerID

where Reservation.RID = @RestaurantID 
and datediff(day, Reservation.ShiftDate, @Date) = 0
and Reservation.RStateID = 1


GO



GRANT EXECUTE ON [Report_GetCustomersByRestaurantIDandDate] TO ExecuteOnlyRole

GO
