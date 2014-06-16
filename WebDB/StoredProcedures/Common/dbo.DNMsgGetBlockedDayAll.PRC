if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNMsgGetBlockedDayAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNMsgGetBlockedDayAll]
GO



CREATE PROCEDURE dbo.DNMsgGetBlockedDayAll
(
  @RID int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
SELECT BlockedDayVW.BlockedDate,
    BlockedDayVW.Message,BlockedDayReason.BlockReason, DateBlocked
FROM BlockedDayVW
inner join BlockedDayReason on BlockedDayVW.BlockReason = BlockedDayReason.reasonID
WHERE BlockedDayVW.RID = @RID
and BlockedDate > getdate()-1
order by BlockedDayVW.BlockedDate


GO

GRANT EXECUTE ON [DNMsgGetBlockedDayAll] TO ExecuteOnlyRole

GO
