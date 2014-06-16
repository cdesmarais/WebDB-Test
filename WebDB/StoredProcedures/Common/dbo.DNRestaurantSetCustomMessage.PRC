if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantSetCustomMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantSetCustomMessage]
GO

CREATE PROCEDURE dbo.DNRestaurantSetCustomMessage
(@RID int
,@MessageTypeID int
,@Message nvarchar(999)
)
AS
--***************************
--** Retrieve LanguageID
--***************************
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID


set @Message = coalesce(@Message,'')
if (@Message = '')
	BEGIN
	--we just use the default large party message
		delete from RestaurantCustomMessage
		WHERE RID = @RID
			   and	LanguageID = @LanguageID
			   and MessageTypeID = @MessageTypeID
	END
else
	if (exists(select message from RestaurantCustomMessage 
				where	RID = @RID 
				and		LanguageID = @LanguageID
				and		MessageTypeID = @MessageTypeID))
		BEGIN
			   UPDATE  RestaurantCustomMessage
			   SET   Message = @Message
			   WHERE RID = @RID
			   and		LanguageID = @LanguageID
			   and MessageTypeID = @MessageTypeID
		END
	else
		BEGIN
			INSERT INTO RestaurantCustomMessage (RID, LanguageID, MessageTypeID,Message)
			values (@RID, @LanguageID, @MessageTypeID,@Message)
		END
GO

GRANT EXECUTE ON [DNRestaurantSetCustomMessage] TO ExecuteOnlyRole

GO
