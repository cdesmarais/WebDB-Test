

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_PaymentType_ListByRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_PaymentType_ListByRestaurant]
GO

create Procedure dbo.OTR_PaymentType_ListByRestaurant
(
	@RestaurantID int
)
as
set nocount on
set transaction isolation level read uncommitted

	/* 
		This SP is used to get payment types as per given parameter
		Content owned by India team, please notify asaxena@opentable.com if changing.

		This SP is same as  Admin_PaymentType_ListByRestaurant
		only modification is- we have used payment table directly instead of join with view beucase it is master data - 
		which remains same for all languages.
	*/

	select		
		PaymentTypeID as PaymentTypeID
	from		
		PaymentTypes 
	where 
		RID = @RestaurantID
	
go

grant execute on [OTR_PaymentType_ListByRestaurant] to ExecuteOnlyRole

go


