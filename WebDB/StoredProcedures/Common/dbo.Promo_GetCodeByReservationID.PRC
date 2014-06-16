if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_GetCodeByReservationID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_GetCodeByReservationID]
GO





CREATE PROCEDURE dbo.Promo_GetCodeByReservationID 

@ReservationID int

AS

Select top 1 Promos.Code,points,Startdate as start_date,Enddate as end_Date,coalesce(EmailMessage,'') as Email_Message
from Promos
inner join PromoReservations on Promos.PromoID = PromoReservations.PromoID
Where PromoReservations.ResID = @ReservationID and Promos.active = 1
GO

GRANT EXECUTE ON [Promo_GetCodeByReservationID] TO ExecuteOnlyRole

GO
