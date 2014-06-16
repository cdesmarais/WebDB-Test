

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationUpdateForChangeWithIncentive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationUpdateForChangeWithIncentive]
GO


CREATE PROCEDURE dbo.DNReservationUpdateForChangeWithIncentive
(@ReservationID int
,@ResDateTime datetime
,@PartySize int
,@Phone nvarchar(255)
,@Notes nvarchar(999)
,@Confirmation int
,@RestaurantID int
,@Business bit
,@FirstTime bit
,@Points int
,@UseCheque int
,@LargeParty bit
,@CCLastFour nvarchar(4)
,@IncentiveID int = 0
,@PromoID int = 0
,@ErbNotes nvarchar(255) = null
,@CallerID int = null
,@retVal nvarchar(255) OUTPUT
)

 AS
SET NOCOUNT ON

if @IncentiveID = 0
BEGIN
	Set @IncentiveID = null
END

if (@CallerID = 0) set @CallerID = null


--***********************
--** Ensure date is not blocked
--***********************
IF EXISTS(
	select DayID from BlockedDay
	where RID = @RestaurantID
	and BlockedDate = CONVERT(Date,@ResDateTime)
)
BEGIN
	RAISERROR('Reservation cannot be made because a block day exists',15,1) --An Error occurred while adding the Reservation to our database.
	RETURN(0)
END

/*Update Reservation ...*/
--Per the BizRule resos older than 30 are not allowed to be updated
--Also ShiftDate needs to be added to the where clause to improve performance of the Partitioned Reservation Table

update Reservation set 
CallerID = IsNull(@CallerID, CallerID), -- Don't allow application to null out the CallerID; in this case preserve the existing ID
ShiftDate = cast(convert(nvarchar,@ResDateTime,110) as datetime),
ResTime = cast(convert(nvarchar,@ResDateTime,108) as datetime) - 2,
PartySize = @PartySize,
ConfNumber = @Confirmation,
ContactPhone = @Phone,
Business = @Business,
FirstTime = @FirstTime,
ResPoints = @Points,
UseDiningCheque = @UseCheque,
LargeParty = @LargeParty,
		CreditCardLastFour = coalesce(@CCLastFour, CreditCardLastFour),
incentiveid = @incentiveID
, notes = @Notes
, ErbNotes = coalesce(@ErbNotes,ErbNotes)
where ResID = @ReservationID
and ShiftDate >= DATEADD(d,-30, GETDATE())
and		RStateID = 1 --** Only the consumer to change to resos that are currently Pending; This Is primarily for console to prevent Cancel followed by Change

if (@@ROWCOUNT = 0)
	RAISERROR('Failed to Update the Reservation. Reservation likely not in a pending state or is too far in the past',16,1)


if (@PromoID <> 0) and not exists(Select PromoID from PromoReservations where resid = @ReservationID)
BEGIN
	Insert into PromoReservations (ResID,PromoID) values (@ReservationID,@PromoID)

	Declare @UserID as int
	Select @CallerID = CallerID, @UserID = CustID from Reservation where Resid = @ReservationID

	Insert into PromoUse(CustID,CallerID,PromoID,Points,RedeemDate,SiteID,ResID) values (@UserID,@CallerID,@PromoID,@Points,getdate(),1,@ReservationID)  
	/*SiteID goes in as 1 because all the others in that table are 1 and no one know what the column is for.  --drew 10-19-01 */
END


if @@ERROR <> 0
	Return(0) --send back null Reservation id to indicate a problem occurred...


set @retval = @ReservationID

GO

GRANT EXECUTE ON [DNReservationUpdateForChangeWithIncentive] TO ExecuteOnlyRole

GO
