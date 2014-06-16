if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procUpdateMessagingSystemStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procUpdateMessagingSystemStatus]
GO

CREATE PROCEDURE dbo.procUpdateMessagingSystemStatus

@MessagingSystemID INT,
@IsActive BIT

AS

-- inserts "message sent" records for MessageCenter alerts

UPDATE MessagingSystem 
SET IsActive = @IsActive
WHERE MessagingSystemID = @MessagingSystemID

GO

GRANT EXECUTE ON [procUpdateMessagingSystemStatus] TO ExecuteOnlyRole

GO