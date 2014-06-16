


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Offer_GetOffersWithSameResoNote]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Offer_GetOffersWithSameResoNote]
go

--
-- Gets the Offers with same reservation notes
-- Note: Comparision will be done by ignoring leading and trailing spaces.
-- 

create Procedure dbo.Offer_GetOffersWithSameResoNote
(	
	@RID int
	,@ResoCode nvarchar(20)	
)	
as

	select 
		*
	from
		RestaurantOfferVW
	where
		RID = @RID
		and OfferStatusId = 1 /* 1 = Active Offer */
		and LTRIM(RTRIM(ResoCode)) = LTRIM(RTRIM(@ResoCode))
	

go

grant execute on [Offer_GetOffersWithSameResoNote] TO ExecuteOnlyRole

go



