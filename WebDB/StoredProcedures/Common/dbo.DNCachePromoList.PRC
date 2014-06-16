if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePromoList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePromoList]
GO

CREATE PROCEDURE dbo.DNCachePromoList
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select PP.PromoID,PromoPageName,PromoPageImage, PP.ImageAltTag,PromoPageDesc,PromoSearchTypeID,PromoIcon,coalesce(MetroID,0) as MetroID,
IconBoldText,IconText,PromoPageCode,active, coalesce(RefCodePage,0) as RefCodePage, 
coalesce(RefCodeLink,0) as RefCodeLink, dbo.fGetNextSelectionDate(PP.PromoID) as SelectionDate, 
coalesce(begindate,dateadd(d,-1,getdate())) as BeginDate, 
coalesce(enddate,dateadd(d,60,begindate)) as EndDate, SortOrder, ExternalURL,
convert(char(12),selectiondate,101) as SelDate_DatePart
from PromoPages PP
left outer join PromoPagesToMetro PPTM on PP.PromoID = PPTM.PromoID and PPTM.OnStartPage = 1
where active = 1
-- if end date is missing have a 60 day grace period for termination..
--and getdate() >= begindate and getdate() <= coalesce(enddate,dateadd(d,60,begindate))
GO

GRANT EXECUTE ON [DNCachePromoList] TO ExecuteOnlyRole

GO


