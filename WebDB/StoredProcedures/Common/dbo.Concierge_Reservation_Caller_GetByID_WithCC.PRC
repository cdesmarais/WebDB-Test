if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Caller_GetByID_WithCC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Caller_GetByID_WithCC]
GO

CREATE Procedure dbo.Concierge_Reservation_Caller_GetByID_WithCC
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
				 res.ShiftDate + 2 + res.ResTime AS ResDateTime
				,res.PartySize AS PartySize
				,res.ContactPhone AS Phone
				,res.ConfNumber AS Confirmation
				,p.Parking AS Parking
				,r.Address1
				,r.Address2
				,r.City
				,r.State
				,r.Zip AS ZipCode
				,r.RName AS RestaurantName
				,r.RID AS RestaurantID
				,coalesce(r.CrossStreet,'') AS CrossStreet
				,r.Phone AS RestaurantPhone
				,res.RStateID AS ReservationState
				,Res.InviteMessage AS Message
				,res.CallerID AS UserID
				,CallerCustomer.CustID AS CustomerID
				,CallerCustomer.FName AS FirstName
				,CallerCustomer.LName AS LastName
				,ma.metroareaid as Metro_Area_ID
				,res.FirstTime as First_Time
				,res.Business as Business
				,Res.Notes as Notes
				,res.ResPoints as Points_For_Reservation
				,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation)) AS Rest_Message
				--,coalesce(rcm.Message,@DefaultConfirmationMessage) as Rest_Message
				,coalesce(res.CompanyID,0) as CompanyID
				,coalesce(res.LargeParty,0) as largeparty
				,coalesce(CreditCardLastFour, '') as cardnumber
				,getdate() as last_modified
				,Promos.code

FROM CallerCustomer 
INNER JOIN Reservation res
ON CallerCustomer.CustID = res.CustID 
INNER JOIN		RestaurantVW r
ON				res.RID = r.RID
LEFT OUTER JOIN ParkingLocal p
ON				p.ParkingID = r.ParkingID 
and				p.LanguageID = r.LanguageID
INNER JOIN		NeighborhoodAVW n 
on				r.neighborhoodid = n.neighborhoodid
and				r.LanguageID = n.LanguageID
INNER JOIN		MetroAreaAVW ma 
on				n.metroareaid = ma.metroareaid
and				ma.LanguageID = r.LanguageID
LEFT OUTER JOIN PromoReservations 
on res.ResID = PromoReservations.ResID
LEFT OUTER JOIN Promos 
on PromoReservations.PromoID = Promos.PromoID
left join	RestaurantCustomMessage rcm
on			r.RID = rcm.RID
and			rcm.MessageTypeID = @Confirmation
and			rcm.LanguageID = r.LanguageID
WHERE (res.ResID = @ReservationID)

GO


GRANT EXECUTE ON [Concierge_Reservation_Caller_GetByID_WithCC] TO ExecuteOnlyRole

GO
