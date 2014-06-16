if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procGetInternalIPs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procGetInternalIPs]
GO

CREATE Procedure dbo.procGetInternalIPs
As

set transaction isolation level read uncommitted
SET NOCOUNT ON

select		distinct IP
from		InternalIP
order by	IP
GO


GRANT EXECUTE ON [procGetInternalIPs] TO ExecuteOnlyRole

GO
