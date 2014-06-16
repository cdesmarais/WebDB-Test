if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Check_CreditCard]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Check_CreditCard]
GO

CREATE Procedure dbo.Restaurant_Check_CreditCard

(
@RestaurantID int,
@PartySize int,
@ResDate datetime,
@retval int  OUTPUT 
)

 AS
if exists  (Select RID 
			from CreditCardDay 
			where CreditCardDay.RID = @RestaurantID 
			and @PartySize >= CreditCardDay.PartySize 
			and @ResDate = BlockedDate
			)
	Select @retval = 1
Else
	Select @retval = 0
GO

GRANT EXECUTE ON [Restaurant_Check_CreditCard] TO ExecuteOnlyRole

GO
