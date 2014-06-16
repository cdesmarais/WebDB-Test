if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_GetNewCompanyByMetroAreaID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_GetNewCompanyByMetroAreaID]
GO




CREATE PROCEDURE dbo.Concierge_GetNewCompanyByMetroAreaID
(
  @metroid int
)
AS

Select Company.CompanyID as Company_ID,Company.CompanyName as compname, ma.MetroAreaName As metroname,CompanyTopList.Rank
From Company
inner join MetroAreaVW ma on Company.metroareaid = ma.metroareaid
inner join CompanyTopList on Company.CompanyID = CompanyTopList.CompanyID
where ma.metroareaid = @metroid
order by Rank
GO

GRANT EXECUTE ON [Concierge_GetNewCompanyByMetroAreaID] TO ExecuteOnlyRole

GO
