if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddUpdateDeleteCreditCardDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddUpdateDeleteCreditCardDay]
GO

-- Procedure adds/updates/deletes credit card days
-- RID, BlockedDate, PartySize
CREATE PROCEDURE dbo.Admin_AddUpdateDeleteCreditCardDay
@RestaurantID int, 		-- restaurantID of restaurant who's date is being blocked
@BlockedDate datetime, 		-- date being blocked
@PartySize int,			-- party size for which credit card is required
@BlockedBy nvarchar(50),		-- who blocked it
@IsDelete int,			-- are we deleting the credit card day? If set to 1, the credit card day will be deleted
@CCMessage nvarchar(999)=NULL	-- special credit card day message if available..

AS

SET NOCOUNT ON

BEGIN TRANSACTION

-- determine if we need to update or insert..
declare @IsUpdate int
set @IsUpdate=0

declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID  

declare @DayID int

-- check if a record exists for this rid/blockedday combination..if it does delete it first
if exists(select * from CreditCardDay where RID = @RestaurantID and BlockedDate =@BlockedDate) OR @IsDelete=1
	BEGIN
		delete from CreditCardDayLocal where dayID in (select CCDayID from CreditCardDayVW where RID = @RestaurantID and BlockedDate =@BlockedDate)
		delete from CreditCardDay where RID = @RestaurantID and BlockedDate =@BlockedDate
	END

-- insert a new record only if its NOT a delete
if @IsDelete=0
	BEGIN	
		Insert into CreditCardDay (RID, BlockedDate,BlockedBy, PartySize) 
		VALUES (@RestaurantID,@BlockedDate,@BlockedBy,@PartySize)
		
		Set @DayID = scope_identity()
		
		Insert into CreditCardDaylocal (DayID, Message, LanguageID) values (@Dayid, @CCMessage, @LanguageID)
	END

COMMIT TRANSACTION

GO

GRANT EXECUTE ON [Admin_AddUpdateDeleteCreditCardDay] TO ExecuteOnlyRole

GO
