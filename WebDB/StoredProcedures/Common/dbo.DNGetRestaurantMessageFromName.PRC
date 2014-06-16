if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetRestaurantMessageFromName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetRestaurantMessageFromName]
GO

CREATE PROCEDURE dbo.DNGetRestaurantMessageFromName
(@RID int
,@MessageName nvarchar(40)
,@retval nvarchar(999) output
)

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--**********************
--** Get Language
--**********************
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID


declare @MessageTypeID int
exec DNGetMessageTypeID @MessageName,@MessageTypeID output

select @retval = coalesce((select Message from RestaurantCustomMessage where rid = @RID and LanguageID = @LanguageID and MessageTypeID = @MessageTypeID)
                         ,(select Message from DefaultMessage where MessageTypeID = @MessageTypeID and LanguageID = @LanguageID))
                         
GO

GRANT EXECUTE ON [DNGetRestaurantMessageFromName] TO ExecuteOnlyRole

GO
