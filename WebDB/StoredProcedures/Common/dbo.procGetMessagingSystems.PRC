if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procGetMessagingSystems]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procGetMessagingSystems]
GO

CREATE PROCEDURE dbo.procGetMessagingSystems
AS

-- Turns off messages SQL Server sends back to the client
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT MessagingSystemID, 
       IsActive 
FROM MessagingSystem

GO

GRANT EXECUTE ON [procGetMessagingSystems] TO ExecuteOnlyRole

GO