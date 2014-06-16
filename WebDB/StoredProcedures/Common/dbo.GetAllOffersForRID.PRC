

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetAllOffersForRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetAllOffersForRID]
go

--
-- Gets all RestaurantOffers that are associated with the given RID
-- 

create Procedure dbo.GetAllOffersForRID
(
	@RID int
	,@ExcludeExpired bit
)
As

	set transaction isolation level read committed

	select	
		*
	from
		RestaurantOfferVW ro
	where
		RID = @RID
		and (OfferStatusId <> 3 or @ExcludeExpired = 0)
	order by
		/* For Expired offers Priority is NULL and if we sort by priority these offers an shown at the top
			We want expired offers to be shown at the bottom, so coalesce is used. Number 1000 is chosen
			becuase Priority can be in range between 1 to 99. */
		coalesce(Priority,1000) 
	
go

grant execute on [GetAllOffersForRID] TO ExecuteOnlyRole

go


