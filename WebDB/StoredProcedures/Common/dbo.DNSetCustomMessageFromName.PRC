if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNSetCustomMessageFromName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNSetCustomMessageFromName]
GO


CREATE PROCEDURE dbo.DNSetCustomMessageFromName
(
	  @RID int
	, @MessageName nvarchar(40)
	, @Message nvarchar(999)
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @MessageTypeID int
exec dbo.DNGetMessageTypeID @MessageName, @MessageTypeID output

--***************************
--** Retrieve LanguageID
--***************************
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID

Delete from RestaurantCustomMessage 
where		rid = @RID
and			LanguageID = @LanguageID 
and			MessageTypeID = @MessageTypeID

if @Message <> '' and @Message is not null
BEGIN
	INSERT INTO RestaurantCustomMessage 
	(RID, LanguageID, MessageTypeID,Message)
	VALUES 
	(@RID, @LanguageID, @MessageTypeID,@Message)
END
GO


GRANT EXECUTE ON [DNSetCustomMessageFromName] TO ExecuteOnlyRole

GO
