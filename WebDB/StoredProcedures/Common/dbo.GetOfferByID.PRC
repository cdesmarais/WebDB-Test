

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetOfferByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetOfferByID]
GO

--
-- Gets the restaurantoffer witht he given ID
-- 

create procedure dbo.GetOfferByID
(
	@OfferID		int
)
as

	set transaction isolation level read committed

	select
		*
	from
		RestaurantOfferVW
	where 
		RestaurantOfferID = @OfferID

GO

GRANT EXECUTE ON [GetOfferByID] TO ExecuteOnlyRole

GO

