if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReservationService_GetReservationDetailsByRIDAndConfNumber]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReservationService_GetReservationDetailsByRIDAndConfNumber]
GO

create procedure dbo.ReservationService_GetReservationDetailsByRIDAndConfNumber
(
	@RID int,
	@ConfNumber int
)
as
set nocount on
set transaction isolation level read uncommitted

select		top 1	
			ReservationID = res.ResID,
      		ReservationState = res.RStateID,						-- This is the reservation status
      		ReservationDateTime = (res.ShiftDate + 2 + res.ResTime),
			ReservationDateTimeUtc = Dateadd(mi, -1*(tz._offsetMI), (res.ShiftDate + 2 + res.ResTime)),
      		PartySize = res.PartySize,
      		Points = res.ResPoints,
      		RestaurantID = res.RID, 
      		ConfirmationNumber = res.ConfNumber,
      		CreditCardLastFour = res.CreditCardLastFour,			-- Confirmation page displays this if a cc is present
      		PartnerID = res.PartnerID,
      		ReservationLanguageID = res.LanguageID,					-- Relevant for emails. The language used when the user made the reservation. 
			reservationLanguageCode = l.LanguageCode,				-- We typically do all consumer communication based on this languageID

      		OfferID = ro.OfferID,
      		OfferClassID = offer.OfferClassID,
      		OfferVersionID = ro.VersionID,
			OfferConfNumber = ro.OfferConfNumber,
      		
      		Notes = res.Notes,
      		ContactPhone = res.ContactPhone,
      		ContactPhoneCountryID = coalesce(country1.CountryID, country2.CountryID),
      		ContactPhoneCountryCode = coalesce(country1.CountryCode, country2.CountryCode),
      		
      		IsRestRef = (case when res.rid = a.RestRefIDFirstIn or res.rid = a.RestRefIDLastIn then convert(BIT, 1) else convert(BIT, 0) end),
      		ReferralCode = coalesce(a.ReferrerIDFirstIn, a.ReferrerIDLastIn, 0),  
      		
      		CallerID = res.CallerID,								-- Various userIds. GPID is the ID we’re moving toward, for all user service operations
      		CustID = res.CustID,
      		GPID = IsNull(gp1._GlobalPersonID, gp2._GlobalPersonID),
      		
      		-- The following data is restaurant specific and should come from the restaurant service
      		RestaurantName = rl.rname,
      		RestaurantAcceptFlower = r.AcceptFlower,
      		
			DomainID = d.DomainID,
			DomainName = d.Domain,
			DomainURL = d.PublicSite
      

from		reservation res

inner join 	Language l
on			res.LanguageID = l.LanguageID

inner join  Restaurant r
on          res.rid = r.rid

left join   restaurantlocal rl
on          res.rid = rl.rid
and         res.LanguageID = rl.LanguageID

inner join 	Domain d
on			r.DomainID = d.DomainID

inner join	TimeZoneVW tz
on			r.TZID = tz.TZID

left join   ReservationOffer ro
on          res.resid = ro.ResID

left join   RestaurantOffer offer
on          offer.RestaurantOfferID = ro.OfferID

left join	ReservationPhoneCountryID resph
on			res.ResID = resph.ResID

left join	Country country1
on			resph.PhoneCountryID = country1.CountryID

left JOIN	Country country2
on			r.Country = country2.CountryID

left join   GlobalPerson gp1
on          res.CallerID = gp1.CallerID 

left join   GlobalPerson gp2
on          res.CustID = gp2.CustID

left join   Attribution_FirstInLastIn a
on          res.ResID = a.ResID

where		res.RID = @RID 
and			res.ConfNumber = @ConfNumber

go

grant execute on [ReservationService_GetReservationDetailsByRIDAndConfNumber] to ExecuteOnlyRole

GO