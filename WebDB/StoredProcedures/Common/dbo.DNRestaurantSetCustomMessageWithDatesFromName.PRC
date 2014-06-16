if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantSetCustomMessageWithDatesFromName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantSetCustomMessageWithDatesFromName]
GO

CREATE PROCEDURE dbo.DNRestaurantSetCustomMessageWithDatesFromName
(@RID int
,@MessageName nvarchar(40)
,@Message nvarchar(999)
,@SpecialEventStartDate datetime
,@SpecialEventEndDate datetime
)
AS



exec DNRestaurantSetCustomMessageFromName @RID,@MessageName,@Message


if @MessageName = 'SpecialEvents'
BEGIN

	--update special events start and end dates 
	--special events are a custom message with id 58
	update RestaurantCustomMessage
	set StartDate = @SpecialEventStartDate, EndDate = @SpecialEventEndDate
	where MessageTypeID = 58 
	and RID = @RID 
	and LanguageID = LanguageID -- Intentionally updating both languages

END


GO

GRANT EXECUTE ON [DNRestaurantSetCustomMessageWithDatesFromName] TO ExecuteOnlyRole

GO
