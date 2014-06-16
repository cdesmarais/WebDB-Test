if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Get_All_Metros]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Get_All_Metros]
GO




CREATE PROCEDURE dbo.Admin_Get_All_Metros

As
SET NOCOUNT ON

Select 
			OTMetro.metroareaid as Metro_Area_ID,
			OTMetro.MetroAreaName as Metro_Name,
			OTMetro.Active,
			OTMetro.SearchLevel as Search_Level,
			OTMetro.Message,
			OTMetro.EmailContact as Email_Contact
from		MetroAreaVW OTMetro
order by	OTMetro.MetroAreaName

GO

GRANT EXECUTE ON [Admin_Get_All_Metros] TO ExecuteOnlyRole

GO
