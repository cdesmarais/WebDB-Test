if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNMsgGetcustomedDayAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNMsgGetcustomedDayAll]
GO

CREATE PROCEDURE dbo.DNMsgGetcustomedDayAll
(
  @RID int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @languageID int
select @languageID = coalesce(LanguageID, DB_LanguageID, OpLanguageID) from DBUserDistinctLanguageVW

	SELECT c.DayID,
		c.customedDate,
		c.Message,
		c.Datecustomed,
		c.DetailsPageOnly,
		@languageID as LanguageID
	FROM customedDayVW c
	WHERE c.RID = @RID
	and customedDate > getdate()-1
union all
	SELECT c.DayID,
		c.customedDate,
		c.Message,
		c.Datecustomed,
		c.DetailsPageOnly,
		LanguageID as LanguageID
	FROM customedDayAVW c
	WHERE c.RID = @RID
	and customedDate > getdate()-1
	and c.DayID not in (select DayID from customedDayVW)

order by customedDate

GO

GRANT EXECUTE ON [DNMsgGetcustomedDayAll] TO ExecuteOnlyRole

GO

