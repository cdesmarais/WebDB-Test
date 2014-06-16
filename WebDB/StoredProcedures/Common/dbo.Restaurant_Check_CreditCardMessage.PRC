if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Check_CreditCardMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Check_CreditCardMessage]
GO

CREATE Procedure dbo.Restaurant_Check_CreditCardMessage
 (
  @RestaurantID int,
  @ResDate datetime,
  @retval nvarchar(999) output
)
As

declare  @CreditCardMessage nvarchar(500)
		,@CreditCard int
		
SET NOCOUNT ON
set transaction isolation level read uncommitted

exec DNGetMessageTypeID 'CreditCard',@CreditCard output
--exec DNGetRestaurantMessage @RestaurantID, @CreditCard ,@CreditCardMessage output ,@Resdate

declare @LanguageID int
select @LanguageID = LanguageID from RestaurantVW where RID = @RestaurantID


set @retval = ''
if exists(Select RID from CreditCardDayVW where RID = @RestaurantID and BlockedDate = @ResDate)
	Select @retval = Coalesce(Message,'') from CreditCardDayVW where RID = @RestaurantID and BlockedDate = @ResDate
if @retval = ''
	Select	@retval = Coalesce(Message,'') 
	from	RestaurantCustomMessage 
	where	RID = @RestaurantID 
	and		MessageTypeID = 11 
	and		LanguageID = @LanguageID
if @retval = ''
	exec DNGetRestaurantMessage @RestaurantID, @CreditCard ,@retval output ,@Resdate
	
GO


GRANT EXECUTE ON [Restaurant_Check_CreditCardMessage] TO ExecuteOnlyRole

GO
