if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Company_Top10_GetMetros]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Company_Top10_GetMetros]
GO

CREATE PROCEDURE dbo.Report_Company_Top10_GetMetros

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select		 OTCompany.MetroAreaID as Metro_Area_ID
			,OTMetroArea.MetroAreaName as Name
from		 CompanyTopList OTList
inner join   Company OTCompany 
on			 OTList.CompanyID = OTCompany.CompanyID
inner join	 MetroAreaVW OTMetroArea 
on			 OTCompany.MetroAreaID = OTMetroArea.MetroAreaID
where		 OTCompany.MetroAreaID is not null 
and			 OTCompany.MetroAreaID <> 1
group by	 OTCompany.MetroAreaID
			,OTMetroArea.MetroAreaName
order by	 OTCompany.MetroAreaID

GO

GRANT EXECUTE ON [Report_Company_Top10_GetMetros] TO ExecuteOnlyRole

GO
