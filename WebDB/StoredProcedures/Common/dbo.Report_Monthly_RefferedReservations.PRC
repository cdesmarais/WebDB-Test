if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Monthly_RefferedReservations]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Monthly_RefferedReservations]
GO

CREATE PROCEDURE dbo.Report_Monthly_RefferedReservations
(
	@DateOfMonthToCheck datetime,
	@Referrer int
)

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted


Select Partner.PartnerName as MadeByPartner,Rname, r.RID, FName, LName, Customer.CustID, Customer.email, 
PartySize, shiftdate, right(convert(nvarchar(27),ResTime,108),14), DateMade, Metroareaname, '0' as Admin, ConsumerTypeTypeName, 
CustomerPhone.Phone, reservationState.RStateName, ReferrerName
from		reservation
inner join	restaurantVW r
on			reservation.RID = r.RID
inner join ReferrerReservationVW 
on			(ReferrerReservationVW.resid = reservation.resid and ReferrerReservationVW.Referrerid=@Referrer)
inner join	referrer 
on			ReferrerReservationVW.referrerID = referrer.referrerID
inner join	reservationState 
on			reservationState.rstateID = reservation.rstateID
inner join	neighborhoodAVW n
on			r.neighborhoodID = n.neighborhoodID
and			r.LanguageID = n.LanguageID
inner join	Customer 
on			reservation.CustID = Customer.CustID
inner join	CustomerPhone 
on			Customer.CustID = CustomerPhone.CustID AND CustomerPhone.IsPrimary = 1
inner join	MetroareaAVW m
on			n.metroareaID = m.metroareaID
and			r.LanguageID = m.LanguageID
inner join	ConsumerTypes 
on			Customer.ConsumerType = ConsumerTypes.ConsumerTypeID
inner join	Partner 
on			Reservation.PartnerID = Partner.PartnerID 
where
			shiftdate > DATEADD(mm, -1, @DateOfMonthToCheck)
AND			DATEDIFF(mm, @DateOfMonthToCheck, shiftDate) = 0
and			n.MetroareaID <> 1 and reservation.RStateID not in (3,4,8,9,10)

union

Select Partner.PartnerName as MadeByPartner,Rname, r.RID, FName, LName, Caller.CallerID as CustID, Caller.email, 
PartySize, shiftdate, right(convert(nvarchar(27),ResTime,108),14), DateMade, Metroareaname, '1' as Admin, ConsumerTypeTypeName, 
CallerPhone.Phone, reservationState.RStateName, ReferrerName
from reservation
inner join	restaurantVW r 
on			reservation.RID = r.RID
inner join	ReferrerReservationVW 
on			(ReferrerReservationVW.resid = reservation.resid and ReferrerReservationVW.Referrerid=@Referrer)
inner join	referrer 
on			ReferrerReservationVW.referrerID = referrer.referrerID
inner join	reservationState 
on			reservationState.rstateID = reservation.rstateID
inner join	neighborhoodAVW n 
on			r.neighborhoodID = n.neighborhoodID
and			r.LanguageID = n.LanguageID
inner join	Caller 
on			reservation.CallerID = Caller.CallerID
inner join	CallerPhone 
on			Caller.CallerID = CallerPhone.CallerID AND CallerPhone.IsPrimary = 1
inner join	MetroareaAVW  m
on			n.metroareaID = m.metroareaID
and			r.LanguageID = m.LanguageID
inner join	ConsumerTypes 
on			Caller.ConsumerType = ConsumerTypes.ConsumerTypeID
inner join	Partner 
on			Reservation.PartnerID = Partner.PartnerID 
where 
			shiftdate > DATEADD(mm, -1, @DateOfMonthToCheck)
AND			DATEDIFF(mm, @DateOfMonthToCheck, shiftDate) = 0
and			n.MetroareaID <> 1 and reservation.RStateID not in (3,4,8,9,10)
order by Rname asc

GO


GRANT EXECUTE ON [Report_Monthly_RefferedReservations] TO ExecuteOnlyRole

GO
