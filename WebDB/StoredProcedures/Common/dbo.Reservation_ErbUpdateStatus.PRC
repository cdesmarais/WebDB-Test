if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_ErbUpdateStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_ErbUpdateStatus]
GO


CREATE procedure dbo.Reservation_ErbUpdateStatus
(
  @RestaurantID				int
,@ConfirmationID			nvarchar(20)
,@Reservation_State_ID		int
,@RetVal int OUTPUT
)
/*revised 8/15/2003 to pass back original reservation state ...*/
as
SET NOCOUNT ON
set transaction isolation level read uncommitted

select @RetVal = Coalesce(RStateID,0) from Reservation 
where  RID        = @RestaurantID
and    ConfNumber  = @ConfirmationID

update Reservation
set    RStateID = @Reservation_State_ID
where  RID        = @RestaurantID
and    ConfNumber  = @ConfirmationID and @Reservation_State_ID <> 3
	
return
GO

GRANT EXECUTE ON [Reservation_ErbUpdateStatus] TO ExecuteOnlyRole

GO
