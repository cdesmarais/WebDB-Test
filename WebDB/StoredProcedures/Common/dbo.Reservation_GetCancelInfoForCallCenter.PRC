if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetCancelInfoForCallCenter]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetCancelInfoForCallCenter]
GO

CREATE PROCEDURE dbo.Reservation_GetCancelInfoForCallCenter
(
@ReservationID integer
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @EmailDestination nvarchar(255), @BccDestination nvarchar(255)

set @EmailDestination = 'support@opentable.com'
set @BccDestination = 'jdavis@opentable.com'
if exists (select 1 from reservation where ResID = @ReservationID and CallerID is not null)
	Begin
		/*get information for caller reso*/
			select res.RName as RestaurantName
			, res.phone as RestaurantPhone
			, r.ConfNumber as Confirmation
			, cc.FName + ' ' + cc.LName as FullName
			, r.ContactPhone as ContactPhone
			, Case when(Coalesce(seatedSize,0) < 1) Then r.Partysize Else seatedSize End as PartySize
			, r.ShiftDate + 2 + r.ResTime as ResDateTime
			, @EmailDestination as AlertDestination
			, @BccDestination as AlertBCC
			from reservation r
			inner join restaurantVW res on r.RID = res.RID 
			inner join CallerCustomer cc on r.CustID = cc.CustID
			where r.ResID = @ReservationID
	End
else
	BEGIN

		/*get information for regular consumer reso*/
			select res.RName as RestaurantName
			, res.phone as RestaurantPhone
			, r.ConfNumber as Confirmation
			, rc.Fname + ' ' + rc.LName as FullName
			, r.ContactPhone as ContactPhone
			, Case when(Coalesce(seatedSize,0) < 1) Then r.Partysize Else seatedSize End as PartySize
			, r.ShiftDate + 2 + r.ResTime as ResDateTime
			, @EmailDestination as AlertDestination
			, @BccDestination as AlertBCC
			from reservation r 
			inner join restaurantVW res on r.RID = res.RID 
			inner join Customer rc on r.CustID = rc.CustID
			where r.ResID = @ReservationID
	END
GO

GRANT EXECUTE ON [Reservation_GetCancelInfoForCallCenter] TO ExecuteOnlyRole

GO
