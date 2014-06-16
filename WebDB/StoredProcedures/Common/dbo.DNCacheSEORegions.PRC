if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheSeoRegion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheSeoRegion]
GO

CREATE PROCEDURE dbo.DNCacheSeoRegion
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select m.MetroAreaID, mn.MacroID, coalesce(RegionName, mn.macroname) as SEORegionName
from SeoRegion sr
inner join MetroAreaVW m on m.MetroAreaID = sr.MetroAreaID
inner join MacroNeighborhoodVW mn on mn.MacroID = sr.MacroID

GO

GRANT EXECUTE ON [DNCacheSeoRegion] TO ExecuteOnlyRole

GO
