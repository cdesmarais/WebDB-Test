if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetMessagingSystems]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetMessagingSystems]
GO

CREATE PROCEDURE dbo.Admin_GetMessagingSystems
AS

-- Turns off messages SQL Server sends back to the client
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

EXEC procGetMessagingSystems

GO

GRANT EXECUTE ON [Admin_GetMessagingSystems] TO ExecuteOnlyRole

GO