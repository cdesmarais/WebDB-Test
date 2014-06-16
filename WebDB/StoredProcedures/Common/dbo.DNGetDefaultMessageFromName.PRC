if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetDefaultMessageFromName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetDefaultMessageFromName]
GO

CREATE PROCEDURE dbo.DNGetDefaultMessageFromName
(@Name nvarchar(40)
,@DefaultValue nvarchar(255) output
)

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

set @DefaultValue = (select Message from DefaultMessageVW dm
					inner join RestaurantMessageType rmt on dm.MessageTypeID = rmt.MessageTypeID
					where Name = @Name)

GO

GRANT EXECUTE ON [DNGetDefaultMessageFromName] TO ExecuteOnlyRole

GO
