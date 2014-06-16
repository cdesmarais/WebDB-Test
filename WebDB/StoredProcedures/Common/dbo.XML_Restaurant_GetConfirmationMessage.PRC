if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_Restaurant_GetConfirmationMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_Restaurant_GetConfirmationMessage]
GO

CREATE PROCEDURE dbo.XML_Restaurant_GetConfirmationMessage
(
@RestaurantID int
,@retVal nvarchar(999) OUTPUT
)

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare  @Confirmation int
		,@DefaultNoTimesMessage nvarchar(500)

exec DNGetMessageTypeID 'Confirmation',@Confirmation output
set @retVal = (select dbo.fGetRestaurantMessage(@RestaurantID, @Confirmation))

GO

GRANT EXECUTE ON [XML_Restaurant_GetConfirmationMessage] TO ExecuteOnlyRole

GO
