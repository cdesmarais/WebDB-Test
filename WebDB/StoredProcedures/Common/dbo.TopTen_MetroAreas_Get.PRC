if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_MetroAreas_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_MetroAreas_Get]
GO


CREATE PROCEDURE [dbo].[TopTen_MetroAreas_Get]
(
    @Active bit = NULL, --optional
    @SearchLevel tinyint = NULL --optional
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select 
			OTMetro.metroareaid as Metro_Area_ID,
			OTMetro.MetroAreaName as Metro_Name,
			OTMetro.Active,
			OTMetro.SearchLevel as Search_Level,
			OTMetro.Message,
			OTMetro.EmailContact as Email_Contact
from	MetroAreaVW OTMetro
where       Active = ISNULL(@Active, Active)
and         SearchLevel = ISNULL(@SearchLevel, SearchLevel)
order by	OTMetro.MetroAreaName

GO

GRANT EXECUTE ON [TopTen_MetroAreas_Get] TO ExecuteOnlyRole

GO

