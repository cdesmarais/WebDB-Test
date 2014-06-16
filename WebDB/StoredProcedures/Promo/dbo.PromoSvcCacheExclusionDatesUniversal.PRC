if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromoSvcCacheExclusionDatesUniversal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].PromoSvcCacheExclusionDatesUniversal
GO

create procedure dbo.PromoSvcCacheExclusionDatesUniversal
as
set nocount on
set transaction isolation level read uncommitted

SELECT
	dbo.fGetRegionID() as RegionID
	,PromoID
	,ExclusionDate
FROM dbo.PromoPageExclusions
WHERE PromoID IS NOT NULL AND ExclusionDate IS NOT NULL

go


grant execute on PromoSvcCacheExclusionDatesUniversal to ExecuteOnlyRole

GO

