if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OpsSetServerLBStatusCode]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OpsSetServerLBStatusCode]
GO

CREATE PROCEDURE dbo.OpsSetServerLBStatusCode
(
	@DestServerName nvarchar(100),
	@LBStatusCode_ID int
)
As

declare @AcceptsTraffic int

select @AcceptsTraffic=AcceptsTraffic
from LBStatusCode
where ID = @LBStatusCode_ID

update	Server
set		AcceptsTraffic = @AcceptsTraffic,
		LBStatusCode = @LBStatusCode_ID
where	ServerName = @DestServerName
GO

GRANT EXECUTE ON [OpsSetServerLBStatusCode] TO ExecuteOnlyRole
GO
