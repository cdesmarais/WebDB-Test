



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNMsgGetcustomedDayAll1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNMsgGetcustomedDayAll1]
GO

CREATE PROCEDURE dbo.DNMsgGetcustomedDayAll1
(
   @RID int
  ,@CustomedDate varchar(7)  
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

--This SP will return Date Specific Messages for perticular restaturant for preticular year/month ( e.g. 2011/07 ) combination.

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
	and c.customedDate > GETDATE() -1 
	--Converting Customed Date into format year/month ( e.g. 2011/07 ) and comparing with @CustomedDate
    and CONVERT(varchar(7),customeddate,111) = @CustomedDate
union all
	SELECT c.DayID,
		c.customedDate,
		c.Message,
		c.Datecustomed,
		c.DetailsPageOnly,
		LanguageID as LanguageID
	FROM customedDayAVW c
	WHERE c.RID = @RID
	and c.DayID not in (select DayID from customedDayVW)
	and c.customedDate > GETDATE() -1
	--Converting Customed Date into format year/month ( e.g. 2011/07 ) and comparing with @CustomedDate
	and CONVERT(varchar(7),customeddate,111) = @CustomedDate

order by customedDate

GO

GRANT EXECUTE ON [DNMsgGetcustomedDayAll1] TO ExecuteOnlyRole

GO



