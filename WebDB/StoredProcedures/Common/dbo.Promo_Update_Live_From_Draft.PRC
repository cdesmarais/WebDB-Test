if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_Update_Live_From_Draft]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_Update_Live_From_Draft]
GO


CREATE PROCEDURE dbo.Promo_Update_Live_From_Draft

@offset int

AS

set nocount on
set transaction isolation level read uncommitted

--tt 32299: this runs on every DB (webdb, webdb_asia, webdb_eu) when a different offset.  a job should run
--this proc three times (one for each DB) every hour with a differnt offset for each DB (TT has more details).  Daylight savings is ignored since we don't care too much if a promo
--starts an hour earlier/later
update PromoPages 
set PromoPageDesc = PromoPageDescDraft,
                PromoPageImage = PromoPageImageDraft,
                SelectionDate = SelectionDateDraft
where ConvertDraftLive = 1 and datediff(dd, BeginDate, dateadd(hour, @offset, getdate())) = 0

GO

GRANT EXECUTE ON [Promo_Update_Live_From_Draft] TO ExecuteOnlyRole

GO
