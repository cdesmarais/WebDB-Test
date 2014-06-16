


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Offer_IsDuplicate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Offer_IsDuplicate]
go

--
-- Check if offer is duplicate
-- 

create Procedure dbo.Offer_IsDuplicate
(	
	@RID int
	,@OfferName nvarchar(50)
	,@OfferDescription nvarchar(500)
	,@StartDate datetime
	,@EndDate datetime
	,@SelectedDays varbinary(1)
	,@Times00_745	VARBINARY(4)
	,@Times08_1545	VARBINARY(4)
	,@Times16_2345	VARBINARY(4)
	,@OfferId int
)	
as
/* An offer is a duplicate if the Offer Name, Offer Description, Start Date, End Date, 
	Start Time, End Time, and selected Days of the Week are the same as another Active offer */

	select
		RestaurantOfferID
		,OfferName
	from
		RestaurantOffer
	where
		RID = @RID
		and OfferStatusID = 1 /* 1 = Active */
		and LTRIM(RTRIM(OfferName)) = LTRIM(RTRIM(@OfferName))
		and LTRIM(RTRIM(OfferDescription)) = LTRIM(RTRIM(@OfferDescription))
		and StartDate = @StartDate
		and EndDate = @EndDate
		and Times00_745 = @Times00_745
		and Times08_1545 = @Times08_1545
		and Times16_2345 = @Times16_2345
		and Days = @SelectedDays	
		/* Exclude the Offer which is being updated.
		 Note: @OfferId is null for new offer and it can not be Zero.  */
		and RestaurantOfferID != coalesce(@OfferId,0) 
go

grant execute on [Offer_IsDuplicate] TO ExecuteOnlyRole

go



