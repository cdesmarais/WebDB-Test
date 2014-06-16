if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNConnectionTest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNConnectionTest]
GO


CREATE Procedure dbo.DNConnectionTest
(
	@ServerIP nvarchar(20)
)
AS
SET NOCOUNT ON
set transaction isolation level read uncommitted

Select	cast(AcceptsTraffic as int) as retval
from	Server 
where	IPAddress = @ServerIP


GO


GRANT EXECUTE ON [DNConnectionTest] TO ExecuteOnlyRole

GO
-- also now used by OTConsole
GRANT EXECUTE ON [DNConnectionTest] TO ConsoleExecuteRole

GO
