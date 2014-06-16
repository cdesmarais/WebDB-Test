if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationUpdateState]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationUpdateState]
GO


CREATE PROCEDURE dbo.DNReservationUpdateState
(
  @nRestaurantID				int
,@sConfirmationID					int
,@nReservationStateID				int
,@nRetVal int OUTPUT
)

as
SET NOCOUNT ON
set transaction isolation level read uncommitted


select @nRetVal = Coalesce(RStateID,0) from Reservation 
where  RID        = @nRestaurantID
and    ConfNumber  = @sConfirmationID

if @nReservationStateID in (3,8)
	begin
		update Reservation
		set    RStateID = @nReservationStateID, CancelledDate = (getdate())
		where  RID        = @nRestaurantID
		and    ConfNumber  = @sConfirmationID and @nReservationStateID <> 3 --Don't update if canceled?
		
	end

else
	begin
update Reservation
set    RStateID = @nReservationStateID
where  RID        = @nRestaurantID
and    ConfNumber  = @sConfirmationID and @nReservationStateID <> 3 --Don't update if canceled?
	
	end 	
--return
GO


GRANT EXECUTE ON [DNReservationUpdateState] TO ExecuteOnlyRole

GO
