if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserCalculateStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserCalculateStatus]
GO

CREATE PROCEDURE dbo.DNUserCalculateStatus
 (
  @UserID int,
  @IsCaller int
 )
As
SET NOCOUNT ON

Declare @ResoNum int, @ThisYear nvarchar(50), @ConsumerType int
Set @ThisYear = YEAR(getdate())
Set @ThisYear = cast(('1/1/' + @ThisYear) as datetime)
if @IsCaller = 0 
BEGIN
	Select @ResoNum = count(ResID), @ConsumerType = ConsumerType, @UserID = reservation.CustID
	from reservation with (nolock) 
	inner join Customer on reservation.CustID = Customer.CustID
	where 
	reservation.CustID = @UserID and shiftDate > @ThisYear and 
	RStateID not in (1,3,4) and ResPoints > 0
	group by ConsumerType, reservation.CustID
END

else
BEGIN
	Select @ResoNum = count(ResID), @ConsumerType = ConsumerType, @UserID = reservation.CallerID
	from reservation with (nolock)
	inner join Caller on reservation.CallerID = Caller.CallerID
	where 
	reservation.CallerID = @UserID and shiftDate > @ThisYear and 
	RStateID not in (1,3,4) and ResPoints > 0
	group by ConsumerType, reservation.CallerID
END

if @ResoNum >= 12 and @ConsumerType <> 5 and @ConsumerType <> 4 and @ConsumerType <> 8 and @ConsumerType <> 9
BEGIN
	if @IsCaller = 0
	BEGIN
		Update Customer set ConsumerType = 4 where CustID = @UserID and ConsumerType <> 5 and ConsumerType <> 8 and ConsumerType <> 9
		
		Exec User_Convert_Consumer_Type @Customer_ID = @UserID,@Caller_ID = null,@Original_Consumer_Type_ID = 1,@New_Consumer_Type_ID = 4
	END

	else
	BEGIN
		Update Caller set ConsumerType = 4 where CallerID = @UserID and ConsumerType <> 5 and ConsumerType <> 8 and ConsumerType <> 9
		
		Exec User_Convert_Consumer_Type @Customer_ID = null,@Caller_ID = @UserID,@Original_Consumer_Type_ID = 1,@New_Consumer_Type_ID = 4
	END

END
GO


GRANT EXECUTE ON [DNUserCalculateStatus] TO ExecuteOnlyRole

GO
