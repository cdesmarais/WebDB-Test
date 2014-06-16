

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_GetProfileAuditInfoForRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_GetProfileAuditInfoForRestaurants]
GO

-- This procedure gets the profile audit information for all restaurants in consumer db
-- This procedure would be used by PTE to pull the audit info to OTRC db
CREATE Procedure [dbo].[OTR_GetProfileAuditInfoForRestaurants]
As

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT  
	   r.Rid AS WebID 
	 , r.RName as RestaurantName
	 , case when LEN(ISNULL(ri.ImageName, '')) > 0 then 1 -- if restaurant has an image then yes else no
		else 0 end as HasPhoto
	 , r.UpdatedDtUTC as ProfileLastModifiedDTUTC	-- las profile update date in UTC format
	 , case when LEN(ISNULL(r.Address1,'') + ISNULL(r.Address2,'')) > 0 then 1 -- if restaurant has an address provided then yes else no
		else 0 End as HasAddress
	 , case when LEN(ISNULL(r.Email,'')) > 0 then 1 -- if restaurant has an email id provided then yes else no
		else 0 End as HasEmail
	 , case when LEN(ISNULL(r.FacebookURL,'')) > 0 then 1 -- if restaurant has a FB url then yes else no
		else 0 End as HasFacebookURL
	 , case when LEN(ISNULL(r.TwitterAccountName,'')) > 0 then 1  -- if restaurant has a Twitter account name then yes else no
		else 0 End as HasTwitterName
	 , case when LEN(ISNULL(r.MenuURL,'')) > 0 then 1 -- if restaurant has a menu url then yes else no
		else 0 End as HasMenuURL
	 , case when (LEN(ISNULL(rcm.Message,'')) > 0 and LEN(ISNULL(ri.PrivateDiningThumbnail, '')) > 0) then 1 -- if restaurant has a profile long description and 
		else 0 end as HasPrivateDining																		 -- a pd listing photo uploaded
	 , case when fts.HasCuisine > 0 then 1	-- if restaurant has a primary or other cuisine specified then yes else no
		else 0 end as HasCuisine
	 , case when LEN(ISNULL(rm.PublicTransit,'')) > 0 then 1 -- if restaurant public transit is provided then yes else no
		else 0 End as HasTransit
	 , r.HasCatering as HasCatering	-- if restaurant has catering then yes else no
	 , case when LEN(ISNULL(rm.SpecialEvents,'')) > 0 then 1	-- if restaurant has any special events then yes else no
		else 0 End as HasSpecialEvents
	 , coalesce(ro.Specials_PromotedOffers, 0) as OffersCount	-- total active offers (specials and promoted) for Restaurant
	 , coalesce(pr.PromoCount, 0) as PromosCount -- total promotions that restaurant has signed up for
	 , GETUTCDATE() as LastModifiedDTUTC
FROM       
	RestaurantVW r  			
		
		left join
			RestaurantMessageVW rm
		on 
			r.RID = rm.RID
		
		left join
			(
				SELECT 
					  fts.RID
					, SUM(ISNULL(LEN(ft.FoodType), 0)) as HasCuisine
					, ft.LanguageID
				FROM
					FoodTypes fts 
				inner join 
					FoodType ft 
				on 
					fts.FoodTypeID = ft.FoodTypeID
				GROUP BY fts.RID, ft.LanguageID
			) as fts
		on 
			r.RID = fts.RID
			and r.LanguageID = fts.LanguageID
		
		left join
			RestaurantCustomMessageVW as rcm
		on
			r.RID = rcm.RID	and rcm.MessageTypeID = 59
		
		left join
			RestaurantImage ri
		on
			r.RID = ri.RID
		
		left join
			(
				SELECT	
					  RID
					, COUNT(*) Specials_PromotedOffers
				FROM 
					RestaurantOffer
				WHERE
					(OfferClassID = 1 or OfferClassID = 4) and OfferStatusID = 1
				GROUP BY
					RID
			) as ro
		on 
			r.RID = ro.RID
		
		left join
			(
				SELECT 
					  pr.RID
					, count(*) as PromoCount 
				FROM 
					PromoRests pr 
				inner join 
					PromoPages pp 
				on 
					pr.PromoID = pp.PromoID and pp.active = 1 
				GROUP BY 
					pr.RID
			) as pr
		on
			r.RID = pr.RID

Go

GRANT EXECUTE ON [OTR_GetProfileAuditInfoForRestaurants] TO ExecuteOnlyRole

Go


