if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Calculate_Status]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Calculate_Status]
GO

--*************************************
--** OBSOLETE: EV: After 11/19/2007 -- replaced with JobSetVIPStatus
--*************************************
CREATE Procedure dbo.User_Calculate_Status
 (
  @UserID int,
  @IsCaller int
 )
As
/*revised for new schema 8/5/2003 --JD*/
SET NOCOUNT ON

set transaction isolation level read uncommitted 

Declare @ResoNum int,@ThisYear nvarchar(50),@ConsumerType int
Set @ThisYear = YEAR(getdate())
Set @ThisYear = cast(('1/1/' + @ThisYear) as datetime)
if @IsCaller = 0 
BEGIN
	Select @ResoNum = count(ResID),@ConsumerType = ConsumerType,@UserID = Reservation.CustID
	from Reservation 
	inner join Customer 
	on Reservation.CustID = Customer.CustID
	where Reservation.CustID = @UserID 
	and ShiftDate > @ThisYear 
	and RStateID not in (1,3,4) 
	and ResPoints > 0
	group by ConsumerType
	,Reservation.CustID
END

else
BEGIN
	Select @ResoNum = count(ResID),@ConsumerType = ConsumerType,@UserID = Reservation.CallerID
	from Reservation 
	inner join Caller 
	on Reservation.CallerID = Caller.CallerID
	where Reservation.CallerID = @UserID 
	and ShiftDate > @ThisYear 
	and RStateID not in (1,3,4) 
	and ResPoints > 0
	group by ConsumerType
	,Reservation.CallerID
END
if @ResoNum >= 12 and @ConsumerType <> 5 and @ConsumerType <> 4 and @ConsumerType <> 8 and @ConsumerType <> 9
BEGIN
	if @IsCaller = 0
	BEGIN
		Update Customer 
		set ConsumerType = 4 
		where CustID = @UserID 
		and ConsumerType <> 5 
		and ConsumerType <> 8 
		and ConsumerType <> 9
		
		Exec User_Convert_Consumer_Type @Customer_ID = @UserID,@Caller_ID = null,@Original_Consumer_Type_ID = 1,@New_Consumer_Type_ID = 4
	END

	else
	BEGIN
		Update Caller 
		set ConsumerType = 4 
		where CallerID = @UserID 
		and ConsumerType <> 5 
		and ConsumerType <> 8 
		and ConsumerType <> 9
		
		Exec User_Convert_Consumer_Type @Customer_ID = null,@Caller_ID = @UserID,@Original_Consumer_Type_ID = 1,@New_Consumer_Type_ID = 4
	END

END
GO

GRANT EXECUTE ON [User_Calculate_Status] TO ExecuteOnlyRole

GO
