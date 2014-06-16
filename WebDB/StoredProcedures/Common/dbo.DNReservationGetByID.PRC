if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationGetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationGetByID]
GO

CREATE Procedure dbo.DNReservationGetByID
 (
  @ReservationID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT 
			res.ResID AS ReservationID
			,res.ShiftDate + 2 + res.ResTime AS ResDateTime
			,res.DateMade as ResoDateMade
			,Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End AS PartySize
			,res.ContactPhone AS Phone
			,res.ConfNumber AS Confirmation
			,res.CustID AS UserID
			,coalesce(res.CallerID,0) AS CallerID
			,r.RID AS RestaurantID
			,r.RName as RestaurantName
			,res.RStateID AS ReservationState
			,res.InviteMessage AS Message
			,res.FirstTime as First_Time
			,res.Business as Business
			,res.UseDiningCheque as Use_Dining_Cheque
			,res.Notes as Notes
			,res.ResPoints as Points
			,res.ErbNotes as ErbNotes
			,convert(nvarchar,res.ShiftDate,110) as Shift_Date
			,coalesce(rm.RMDesc,' ') As Description
			,coalesce(res.LargeParty,0) As largeparty
			,Promos.code As code
			,(case when res.IncentiveID is null then 0 else 1 end) As IsIncented
			,(case when res.CreditCardLastFour is not null then 1 else 0 end) as HasCC
			,res.CreditCardLastFour as CCLast4, res.IncentiveID
			,res.LanguageID
			,d.PrimaryLanguageID
			,r.DomainID
			,(case when rr.RID is not null then 1 else 0 end) as IsRestReferred
			,l.LanguageCode as LANGUAGE
			,pl.LanguageCode AS PrimaryLanguage
			,d.PublicSite as Domain
			,res.PartnerID
			,offer.OfferID
			,offer.VersionID as OfferVersionID
			,offer.OfferConfNumber as OfferConfirmationNumber
			,resoffer.OfferClassID
			,resoffer.OfferName			
			,resoffer.ExcludesService
			,resoffer.ExcludesTax
			,resoffer.NoteToDiners
			,coalesce(resPhoneCountry.PhoneCountryID, r.Country) as PhoneCountryID
FROM		(
	select top 1 
	*   
	from Reservation res
	where res.ResID = @ReservationID
	) res
inner join	RestaurantAVW r  -- Use View All becuase no references are made to parent table
on			res.RID = r.RID
and			r.LanguageID = res.LanguageID
inner join 	Language l
on			res.LanguageID = l.LanguageID
inner join 	Domain d
on			r.DomainID = d.DomainID
inner join 	Language pl
on			d.PrimaryLanguageID= pl.LanguageID
inner join	RestaurantMessageAVW rm 
on			r.RID = rm.RID
and			rm.LanguageID = r.LanguageID
LEFT JOIN	PromoReservations 
on			res.ResID = PromoReservations.ResID
LEFT JOIN	Promos 
on			PromoReservations.PromoID = Promos.PromoID
LEFT JOIN	ReferrerRestaurantReservationVW rr
on			res.ResID = rr.resid
and			res.RID = rr.RID 
LEFT JOIN	ReservationOffer offer
on			res.ResID = offer.ResID		
LEFT JOIN	ReservationOfferVW resoffer --Note this view is not an extension of ReservationOffer, but RestaurantOffer (misnomer)
on			offer.OfferID = resoffer.OfferID
LEFT JOIN	ReservationPhoneCountryID resPhoneCountry
on			res.ResID = resPhoneCountry.ResID

GO


GRANT EXECUTE ON [DNReservationGetByID] TO ExecuteOnlyRole

GO

