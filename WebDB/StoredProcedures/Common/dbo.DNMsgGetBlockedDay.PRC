if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNMsgGetBlockedDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNMsgGetBlockedDay]
GO


CREATE PROCEDURE dbo.DNMsgGetBlockedDay
(
  @RID int,
  @BlockedDate datetime
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
SELECT 
    BlockedDayVW.Message

FROM BlockedDayVW
WHERE BlockedDayVW.BlockedDate = @BlockedDate and BlockedDayVW.RID = @RID
GO

GRANT EXECUTE ON [DNMsgGetBlockedDay] TO ExecuteOnlyRole

GO
