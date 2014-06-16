if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddUpdateDeleteCreditCardDayDefault]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddUpdateDeleteCreditCardDayDefault]
GO

-- Procedure adds/updates/deletes blocked dates
CREATE PROCEDURE dbo.Admin_AddUpdateDeleteCreditCardDayDefault
@RestaurantID int, 		-- restaurantID of restaurant who's date is being blocked
@BlockedDate datetime, 		-- date being blocked
@BlockedBy nvarchar(50),	-- who blocked it
@IsDelete int = 0		-- are we deleting the credit card day? If set to 1, the credit card day will be deleted

AS

SET NOCOUNT ON

BEGIN TRANSACTION

-- determine if we need to update or insert..
declare @IsUpdate int, @Dayid int
set @IsUpdate=0

-- check if a record exists for this rid/cc combination..if it does delete it first
if exists(select * from CreditCardDay where RID = @RestaurantID and BlockedDate =@BlockedDate) OR @IsDelete=1
	BEGIN
		-- delete and then insert..
		DELETE FROM [CreditCardDaylocal] WHERE DayID IN (
		SELECT CCDayID FROM [CreditCardDay] WHERE RID = @RestaurantID AND BlockedDate = @BlockedDate)
		

		DELETE FROM [CreditCardDay] WHERE RID = @RestaurantID AND BlockedDate = @BlockedDate

	END

-- insert cc day..
if @IsDelete=0
	BEGIN
		Insert into CreditCardDay (RID, BlockedDate,BlockedBy, PartySize) 
		VALUES (@RestaurantID,@BlockedDate,@BlockedBy,'1')

		Set @Dayid = scope_identity()

		-- insert cc day local..
		Insert into CreditCardDaylocal (DayID, Message, LanguageID)
		SELECT 	@Dayid as DayID, 
			NULL, 
			DefaultMessage.LanguageID 
		FROM 		DefaultMessage 
		INNER JOIN 	[RestaurantLocal] 
		ON 		[DefaultMessage].[LanguageID] = [RestaurantLocal].[LanguageID]
		WHERE [MessageTypeID] = 11 AND rid = @RestaurantID
	END

COMMIT TRANSACTION

GO

GRANT EXECUTE ON [Admin_AddUpdateDeleteCreditCardDayDefault] TO ExecuteOnlyRole

GO
