if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[erbGetInternalIPs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[erbGetInternalIPs]
GO

CREATE Procedure dbo.erbGetInternalIPs
As

set transaction isolation level read uncommitted
SET NOCOUNT ON

Exec procGetInternalIPs
GO


GRANT EXECUTE ON [erbGetInternalIPs] TO ExecuteOnlyRole

GO
