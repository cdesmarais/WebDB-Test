if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetMessageTypeID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetMessageTypeID]
GO

CREATE PROCEDURE dbo.DNGetMessageTypeID
(@MessageName nvarchar(40)
,@TypeID int output)
AS
SET NOCOUNT ON

declare @id int

select @id = MessageTypeID from RestaurantMessageType where Name = @MessageName

set @TypeID = coalesce(@id,0)

Return(0)
GO

GRANT EXECUTE ON [DNGetMessageTypeID] TO ExecuteOnlyRole

GO
