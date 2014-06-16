if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ConnectionTest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ConnectionTest]
GO


CREATE Procedure dbo.ConnectionTest
(
@ServerIP nvarchar(20)
)
AS
SET NOCOUNT ON

--*********************************************
--** Used by OTUK testconnection page ; should be replaced with DNConnectionTest
--*********************************************
 
Select	cast(AcceptsTraffic as int) as retval
from	Server 
where	IPAddress = @ServerIP



--set @retVal = 1
GO


GRANT EXECUTE ON [ConnectionTest] TO ExecuteOnlyRole

GO