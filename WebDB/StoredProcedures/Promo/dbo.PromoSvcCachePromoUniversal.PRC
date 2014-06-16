if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromoSvcCachePromoUniversal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].PromoSvcCachePromoUniversal
GO

create procedure dbo.PromoSvcCachePromoUniversal
as
set nocount on
set transaction isolation level read uncommitted

SELECT
	dbo.fGetRegionID() as RegionID
	,pp.PromoID
	,pp.PromoSearchTypeID
	,pp.active
	,COALESCE(pp.RefCodePage,0) AS RefCodePage
	,COALESCE(pp.RefCodeLink,0) AS RefCodeLink
	,dbo.fGetNextSelectionDate(pp.PromoID) AS SelectionDate
	,COALESCE(pp.begindate,dateadd(d,-1,getdate())) AS BeginDate
	,COALESCE(pp.enddate,dateadd(d,60,begindate)) AS EndDate
	,pp.SortOrder
	,pp.ChildPromoID
	,COALESCE(pp.SuppressDIP,0) AS SuppressDIP
	,pp.SuppressPrice	
	,pp.ShowOnStartPage
	,COALESCE(pppg.PromoGroupTypeID, 0) AS PromoGroupTypeID
	,pp.EventStartDate
	,pp.EventEndDate
FROM dbo.PromoPages pp
LEFT OUTER JOIN dbo.PromoPagesToPromoGroups pppg on pp.PromoID = pppg.PromoID  AND pppg.Active = 1

go


grant execute on PromoSvcCachePromoUniversal to ExecuteOnlyRole

GO

