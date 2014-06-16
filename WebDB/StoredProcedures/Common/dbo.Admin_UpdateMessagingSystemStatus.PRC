if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdateMessagingSystemStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdateMessagingSystemStatus]
GO

CREATE PROCEDURE dbo.Admin_UpdateMessagingSystemStatus

@MessagingSystemID INT,
@IsActive BIT

AS

-- Call the inner proc - procGetMessagingSystems
exec procUpdateMessagingSystemStatus @MessagingSystemID, @IsActive

GO

GRANT EXECUTE ON [Admin_UpdateMessagingSystemStatus] TO ExecuteOnlyRole

GO