if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Caller_GetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Caller_GetByID]
GO


CREATE Procedure dbo.Concierge_Reservation_Caller_GetByID
 (
  @ReservationID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @Confirmation int,@DefaultConfirmationMessage nvarchar(255)
exec DNGetMessageTypeID 'Confirmation',@Confirmation output
--exec DNGetDefaultMessageFromName 'Confirmation',@DefaultConfirmationMessage output

SELECT 
				Reservation.ShiftDate + 2 + Reservation.ResTime AS ResDateTime
				,Reservation.PartySize AS PartySize
				,Reservation.ContactPhone AS Phone
				,Reservation.ConfNumber AS Confirmation
				,p.Parking AS Parking
				,r.Address1,r.Address2
				,r.City
				,r.State
				,r.Zip AS ZipCode
				,r.RName AS RestaurantName
				,r.RID AS RestaurantID
				,coalesce(CrossStreet,'') AS CrossStreet
				,r.Phone AS RestaurantPhone
				,Reservation.RStateID AS ReservationState
				,Reservation.InviteMessage AS Message
				,Reservation.CallerID AS UserID
				,CallerCustomer.CustID AS CustomerID
				,CallerCustomer.FName AS FirstName
				,CallerCustomer.LName AS LastName
				,ma.metroareaid as Metro_Area_ID
				,Reservation.FirstTime as First_Time
				,Reservation.Business as Business
				,Reservation.Notes as Notes
				,Reservation.ResPoints as Points_For_Reservation
				,Reservation.PartnerID as PartnerID
				,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation)) AS Rest_Message				
				,coalesce(Reservation.CompanyID,0) as CompanyID
				,coalesce(Reservation.LargeParty,0) as largeparty
				,'' as cardnumber
				,getdate() as last_modified,Promos.code				
FROM CallerCustomer 
INNER JOIN Reservation 
ON CallerCustomer.CustID = Reservation.CustID 
INNER JOIN RestaurantVW r
ON Reservation.RID = r.RID
LEFT OUTER JOIN ParkingLocal p
ON				p.ParkingID = r.ParkingID 
and				p.LanguageID = r.LanguageID
INNER JOIN		NeighborhoodAVW n 
on				r.neighborhoodid = n.neighborhoodid
and				r.LanguageID = n.LanguageID
INNER JOIN MetroAreaAVW ma
on				n.metroareaid = ma.metroareaid
and				r.LanguageID = ma.LanguageID
LEFT join RestaurantCustomMessage rcm
on				r.RID = rcm.RID
and				rcm.MessageTypeID = @Confirmation
and				rcm.LanguageID = r.LanguageID
LEFT OUTER JOIN PromoReservations 
on Reservation.ResID = PromoReservations.ResID
LEFT OUTER JOIN Promos 
on PromoReservations.PromoID = Promos.PromoID

WHERE (Reservation.ResID = @ReservationID)

GO

GRANT EXECUTE ON [Concierge_Reservation_Caller_GetByID] TO ExecuteOnlyRole

GO
