
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNMsgGetcustomedDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNMsgGetcustomedDay]
GO





CREATE PROCEDURE dbo.DNMsgGetcustomedDay
(
  @RID int,
  @customedDate datetime
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
SELECT 
    customedDayVW.Message

FROM customedDayVW
WHERE customedDayVW.customedDate = @customedDate and customedDayVW.RID = @RID



GO

GRANT EXECUTE ON [DNMsgGetcustomedDay] TO ExecuteOnlyRole

GO
