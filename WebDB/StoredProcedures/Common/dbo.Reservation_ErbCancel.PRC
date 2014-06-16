GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_ErbCancel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_ErbCancel]
GO







CREATE  procedure dbo.Reservation_ErbCancel

  @RestaurantID		int
,@ConfirmationNo	int

as

set nocount on
set transaction isolation level read uncommitted

--************************************
--** Proc tuned to work with Reso Split
--** Only allow resos in past 30 days to be modified
--************************************
set rowcount 1
update Reservation
set		RStateID = 8
		,CancelledDate = getdate()
where	RID = @RestaurantID 
and		ConfNumber = @ConfirmationNo
and		ShiftDate >= DATEADD(d,-30, GETDATE())
set rowcount 0

declare @ResID	int

--Get the Reservation ID
select	top 1
		@ResID = ResID
from	Reservation
where	RID = @RestaurantID
and		ConfNumber = @ConfirmationNo
and		ShiftDate >= DATEADD(d,-30, GETDATE())

if @ResID is not null
	--Delete from TemplateReservation if it's there or not
delete 
from TemplateReservation 
where ResID = @ResID

return


GO


GRANT EXECUTE ON [Reservation_ErbCancel] TO ExecuteOnlyRole

GO
