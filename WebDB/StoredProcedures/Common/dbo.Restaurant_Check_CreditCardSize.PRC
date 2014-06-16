if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Check_CreditCardSize]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Check_CreditCardSize]
GO




CREATE Procedure dbo.Restaurant_Check_CreditCardSize

(
@RestaurantID int,
@ResDate datetime,
@PartySize int,
@retval int  OUTPUT 
)

 AS
if exists  (
	Select RID from CreditCardDay 
	where RID = @RestaurantID and @PartySize >= PartySize and @ResDate = BlockedDate
	)
              Select @retval = PartySize from CreditCardDay where RID = @RestaurantID and BlockedDate = @ResDate
Else
	Select @retval = 99
GO

GRANT EXECUTE ON [Restaurant_Check_CreditCardSize] TO ExecuteOnlyRole

GO
