

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_Offer_ListByRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_Offer_ListByRestaurant]
GO

create procedure dbo.OTR_Offer_ListByRestaurant
(
	@RestaurantID int
)
as
set nocount on
set transaction isolation level read uncommitted

	/* 
		This SP is used to get offer list for restaurant
		Content owned by India team, please notify asaxena@opentable.com if changing.

		This SP is same as  Admin_Offer_ListByRestaurant 
		only modification is- we have used offers table directly instead of join with view beucase it is master data - 
		which remains same for all languages.
	*/

	select		
		offerID AS OfferID
	from
		Offers 
	where 
		RID = @RestaurantID

go

grant execute on [OTR_Offer_ListByRestaurant] to ExecuteOnlyRole

go


