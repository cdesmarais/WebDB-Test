--$ create proc csGetInternalIPs
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csGetInternalIPs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csGetInternalIPs]
GO


CREATE Procedure dbo.csGetInternalIPs
As

set transaction isolation level read uncommitted
SET NOCOUNT ON

Exec procGetInternalIPs
GO

GRANT EXECUTE ON [csGetInternalIPs] TO ExecuteOnlyRole
GO
