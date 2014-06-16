

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddRestaurantOfferAuditLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddRestaurantOfferAuditLog]
GO

-- Audit log Restaurant offer on update.  
-- This stroed procedure add older version of Restuarant offer in RestaurantOfferAuditLog
-- table before update.

create Procedure dbo.AddRestaurantOfferAuditLog
(
	@RestaurantOfferID	INT
)
as

	insert into RestaurantOfferAuditLog
	(
		RestaurantOfferID 
		,OfferTypeID
		,OfferStatusID
		,RID
		,OfferName
		,StartDate
		,EndDate
		,Days
		,Times00_745
		,Times08_1545
		,Times16_2345
		,DailyMaxCovers
		,SeatedCovers
		,PendingCovers
		,ResoCode
		,OfferDescription
		,MinPartySize
		,MaxPartySize
		,ExcludesTaxTip
		,NoteToDiners
		,CreatedDtUTC
		,CreatedBy
		,UpdatedDtUTC
		,UpdatedBy
		,PostedDtUTC
		,Priority
		,OfferVersion
		,DisplayOnOTWebsite
		,DisplayOnRestWebsite
		,LockOverrideDTUTC
		,MealDiscountPercent
		,ApplicableDiscountMealItemID
		,BeverageDiscountPercent
		,ApplicableBeverageScopeID
		,ApplicableBeverages
		,Buy1Get1RequiredItemID
		,Buy1Get1DiscountedItemID
		,Buy1Get1DiscountPercent
		,ComplimentaryItemID
		,PrixFixeNumberOfCourses
		,PrixFixePricePerPerson
		,OtherPricePerPerson
	)
	select  
		RestaurantOfferID
		,OfferTypeID
		,OfferStatusID
		,RID
		,OfferName
		,StartDate
		,EndDate
		,Days
		,Times00_745
		,Times08_1545
		,Times16_2345
		,DailyMaxCovers
		,SeatedCovers
		,PendingCovers
		,ResoCode
		,Description
		,MinPartySize
		,MaxPartySize
		,ExcludesTaxTip
		,NoteToDiners
		,CreatedDtUTC
		,CreatedBy
		,UpdatedDtUTC
		,UpdatedBy
		,PostedDtUTC
		,Priority
		,OfferVersion
		,DisplayOnOTWebsite
		,DisplayOnRestWebsite
		,LockOverrideDTUTC
		,MealDiscountPercent
		,ApplicableDiscountMealItemID
		,BeverageDiscountPercent
		,ApplicableBeverageScopeID
		,ApplicableBeverages
		,Buy1Get1RequiredItemID
		,Buy1Get1DiscountedItemID
		,Buy1Get1DiscountPercent
		,ComplimentaryItemID
		,PrixFixeNumberOfCourses
		,PrixFixePricePerPerson
		,OtherPricePerPerson
	from 
		 RestaurantOfferVw
	where
		RestaurantOfferID = @RestaurantOfferID

GO

GRANT EXECUTE ON [AddRestaurantOfferAuditLog] TO ExecuteOnlyRole

GO

