


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Offer_UnlockForEdit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Offer_UnlockForEdit]
go

--
-- Unlock the Offer for edit
-- 

create Procedure dbo.Offer_UnlockForEdit
(	
	@OfferId int
	,@UnlockedBy nvarchar(100)	
)	
as

	update 
		RestaurantOffer
	set
		LockOverrideDTUTC = getutcdate()
		,UnlockedBy = @UnlockedBy
	where
		RestaurantOfferId = @OfferId	

go

grant execute on [Offer_UnlockForEdit] TO ExecuteOnlyRole

go



