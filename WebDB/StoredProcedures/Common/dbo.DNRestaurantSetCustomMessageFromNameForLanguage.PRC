if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantSetCustomMessageFromNameForLanguage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantSetCustomMessageFromNameForLanguage]
GO

CREATE PROCEDURE dbo.DNRestaurantSetCustomMessageFromNameForLanguage
(
@RID int
,@LanguageID int
,@MessageName nvarchar(40)
,@Message nvarchar(999)
)
AS
declare @MessageTypeID int
exec dbo.DNGetMessageTypeID @MessageName,@MessageTypeID output

set @Message = coalesce(@Message,'')
if (@Message = '')
	BEGIN
	--we just use the default large party message
		delete from RestaurantCustomMessage
		where	RID = @RID
			and LanguageID = @LanguageID
			and	MessageTypeID = @MessageTypeID
	END
else
	if (exists(select message from RestaurantCustomMessage 
				where	RID = @RID 
					and	LanguageID = @LanguageID
					and	MessageTypeID = @MessageTypeID))
		BEGIN
			   update  RestaurantCustomMessage
			   set   Message = @Message
			   where	RID = @RID
				   and	LanguageID = @LanguageID
				   and	MessageTypeID = @MessageTypeID
		END
	else
		BEGIN
			insert into RestaurantCustomMessage (RID, LanguageID, MessageTypeID,Message)
			values (@RID, @LanguageID, @MessageTypeID, @Message)
		END
GO

GRANT EXECUTE ON [DNRestaurantSetCustomMessageFromNameForLanguage] TO ExecuteOnlyRole

GO
