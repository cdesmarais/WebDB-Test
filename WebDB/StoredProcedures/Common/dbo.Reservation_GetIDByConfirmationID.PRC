if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetIDByConfirmationID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetIDByConfirmationID]
GO





CREATE Procedure dbo.Reservation_GetIDByConfirmationID

@RestaurantID		int
,@ConfirmationID	nvarchar(20)
,@ReservationID	int OUTPUT

as

set nocount on
set transaction isolation level read uncommitted

declare @xResID	int


select @xResID = ResID
from   Reservation
where  RID = @RestaurantID
and    ConfNumber = @ConfirmationID
if @xResID is null
	set @ReservationID = 0
else
	set @ReservationID = @xResID


return
GO

GRANT EXECUTE ON [Reservation_GetIDByConfirmationID] TO ExecuteOnlyRole

GO
