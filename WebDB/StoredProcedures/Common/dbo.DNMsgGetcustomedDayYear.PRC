



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNMsgGetcustomedDayYear]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNMsgGetcustomedDayYear]
GO

CREATE PROCEDURE dbo.DNMsgGetcustomedDayYear
(
   @RID int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

--This Store procedure returns all those year in which custom date in configured for perticular restaurnat.

select distinct 
	datepart(year,customedDate) as CustomedDate 
from 
	CustomedDay c
where 
	c.RID = @RID
	and CustomedDate >= GETDATE()
order by
	CustomedDate

GO

GRANT EXECUTE ON [DNMsgGetcustomedDayYear] TO ExecuteOnlyRole

GO



