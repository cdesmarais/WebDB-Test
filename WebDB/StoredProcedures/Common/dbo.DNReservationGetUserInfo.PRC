if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationGetUserInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationGetUserInfo]
GO

CREATE Procedure dbo.DNReservationGetUserInfo
 (
  @ReservationID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted


Declare @CustomerID int, @CallerID int

Select  top 1
		@CustomerID = CustID, 
		@CallerID = CallerID
from	reservation
where   resid = @ReservationID

if @CallerID is null
BEGIN
	Select		@CustomerID CustID, 
				@CallerID CallerID, 
				sum(case when rstateID = 4 then 1 else 0 end) as NoShow,
				sum(case when rstateID not in (1,3,4) then 1 else 0 end) as Seated,
				email, 
				ConsumerType, 
				sum(case when rstateID = 1 then 1 else 0 end) as Pending
	from		reservation res
	inner join	customer 
	on			res.custID = customer.custID
	where		res.custid = @CustomerID
	group by	email,
				ConsumerType
END
else
BEGIN
	Select		@CustomerID CustID, 
				@CallerID CallerID, 
				sum(case when rstateID = 4 then 1 else 0 end) as NoShow,
				sum(case when rstateID not in (1,3,4) then 1 else 0 end) as Seated,
				email, 
				ConsumerType, 
				sum(case when rstateID = 1 then 1 else 0 end) as Pending
	from		reservation res
	inner join	Caller 
	on			res.CallerID = Caller.CallerID
	where		res.CallerID = @CallerID
	group by	email,
				ConsumerType

END
GO


GRANT EXECUTE ON [DNReservationGetUserInfo] TO ExecuteOnlyRole

GO
