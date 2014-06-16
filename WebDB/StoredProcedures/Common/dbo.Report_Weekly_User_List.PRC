if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Weekly_User_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Weekly_User_List]
GO

CREATE PROCEDURE dbo.Report_Weekly_User_List

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

(
select top 250000
	Customer.CustID as UserID,
	Customer.FName,
	Customer.LName,
	Customer.email,
	Customer.CreateDate,
	m.MetroAreaName,
	isNull(count(Reservation.ResID),0) as ResoCount,
	max(Reservation.DateMade) as LastResoDate,
	cast(Customer.SendAnnouncements as Int) as OptInStatus,
	Customer.points,
	'N' as IsAdmin
from Customer
inner join MetroAreaVW m
on			m.MetroAreaID = Customer.MetroAreaID
left join Reservation on Reservation.CustID = Customer.CustID

group by Customer.CustID,
	Customer.FName,
	Customer.LName,
	Customer.email,
	Customer.CreateDate,
	m.MetroAreaName,
	cast(Customer.SendAnnouncements as Int) ,
	Customer.points
)
UNION

(select
	Caller.CallerID as UserID,
	Caller.FName,
	Caller.LName,
	Caller.email,
	Caller.CreateDate,
	m.MetroAreaName,
	isNull(count(Reservation.ResID),0) as ResoCount,
	max(Reservation.DateMade) as LastResoDate,
	cast(Caller.SendAnnouncements as Int) as OptInStatus,
	Caller.points,
	'Y' as IsAdmin
from Caller
inner join	MetroAreaVW m 
on			m.MetroAreaID = Caller.MetroAreaID 
left join	Reservation on Reservation.CallerID = Caller.CallerID 
where		Caller.PositionID = 3

group by Caller.CallerID,
	Caller.FName,
	Caller.LName,
	Caller.email,
	Caller.CreateDate,
	m.MetroAreaName,
	cast(Caller.SendAnnouncements as Int),
	Caller.points

)
 
GO


GRANT EXECUTE ON [Report_Weekly_User_List] TO ExecuteOnlyRole

GO
