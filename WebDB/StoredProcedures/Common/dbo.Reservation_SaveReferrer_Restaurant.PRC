if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_SaveReferrer_Restaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_SaveReferrer_Restaurant]
GO



CREATE Procedure dbo.Reservation_SaveReferrer_Restaurant
(
	@Restaurant_ID nvarchar(255),
	@ReservationID int,
	@retval int OUTPUT
)
AS
SET NOCOUNT ON
Declare @gobalError int
Declare @HasPoints int

--*** Check to see if an entry has already been created
--*** if so goto ResAlreadyExists
declare @prevRefRID int
select @prevRefRID = rid from ReferrerRestaurantReservation where resID = @ReservationID
if @prevRefRID is not null goto ResAlreadyExists


Select	@HasPoints = (case when ResPoints = 0 then 0 else 1 end) 
from	reservation with (nolock) 
where	resid = @ReservationID


Begin Tran

Insert into ReferrerRestaurantReservation (RID,ResID,HasPoints)
values (@Restaurant_ID,@ReservationID,@HasPoints)

if (@@error <> 0) goto nogood
set @gobalError = @@ERROR

IF @gobalError <> 0 GOTO nogood

SELECT @retval= 1

commit

RETURN(1)

nogood:
	Rollback
	
	declare @ErrorMsg as nvarchar(4000)
	set @ErrorMsg = ' @Restaurant_ID : '+ ISNULL(@Restaurant_ID,'') + ' @ReservationID : '+cast(ISNULL(@ReservationID, '')  as nvarchar(10)) + ' Error: ' + convert(nvarchar, @gobalError)
	exec DNErrorAdd 555, Reservation_SaveReferrer_Restaurant, @ErrorMsg , 1
	
	RETURN(0)

ResAlreadyExists:
	if @prevRefRID != @Restaurant_ID 
	begin
		--*** If the RIDs differ then raise an error
		declare @message varchar(2000)
		set @message = 'Resid already exists ResID: ' + convert(varchar, @ReservationID) +  ' RestID: ' + convert(varchar, @prevRefRID)
		Raiserror(@message,16,1)
	end
	Return(0)
	
GO

GRANT EXECUTE ON [Reservation_SaveReferrer_Restaurant] TO ExecuteOnlyRole

GO
