

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Offer_GetExpireToday]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Offer_GetExpireToday]
go

create Procedure dbo.Offer_GetExpireToday

as

/*
This stored procedure is used to get the non expired offers which will expire or should expire Today
*/ 
	set transaction isolation level read committed

	select 
		restOffer.RestaurantOfferID
		,restOffer.OfferStatusID
		,restOffer.RID
		,restOffer.OfferName
		,restOffer.Description as OfferDescription
		,restOffer.StartDate
		,restOffer.EndDate
		,restOffer.Times00_745
		,restOffer.Times08_1545
		,restOffer.Times16_2345
		,restOffer.CreatedBy
		,restOffer.UpdatedBy
		,restOffer.UpdatedDTUTC
		,restOffer.UpdatedDTLocal
		,dbo.fConvertFromUTC(getutcdate(),restOffer.TimeZoneID) as CurrentDateRestTimeZone
		,l.LanguageCode
		,l.LanguageID
		,restvw.DomainID
		,restvw.RName
		,restvw.City
	from
		RestaurantOfferVW restOffer

		inner join restaurantVW restvw  
		on restOffer.RID = restvw.RID
		
		inner join Domain dl /* To get Domain based on DomainId */
		on restvw.DomainID = dl.DomainId

		left join Domain dm /* To get language Code based on Country */
		on restvw.Country = dm.PrimaryCountryID

		left join Language l 
		on coalesce(dm.PrimaryLanguageId,dl.PrimaryLanguageId) = l.LanguageId

	where 
		OfferStatusID <> 3 /* Exclude already Expired Offers */
		and restOffer.EndDate <= DATEADD(D, 0, DATEDIFF(D, 0, dbo.fConvertFromUTC(getutcdate(),restOffer.TimeZoneID)))
go

grant execute on [Offer_GetExpireToday] TO ExecuteOnlyRole

go



