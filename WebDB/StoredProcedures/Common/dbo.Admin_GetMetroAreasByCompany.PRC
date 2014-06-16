if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetMetroAreasByCompany]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetMetroAreasByCompany]
GO

CREATE PROCEDURE dbo.Admin_GetMetroAreasByCompany @CompanyID int
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		me.metroareaid as Metro_Area_ID,
			me.MetroAreaName as Name,
			me.Active
FROM		MetroAreaVW me
INNER JOIN	Company		co 
on			co.metroareaid = me.metroareaid  
where		co.companyID = @CompanyID		
Order by	MetroAreaName

GO

GRANT EXECUTE ON [Admin_GetMetroAreasByCompany] TO ExecuteOnlyRole

GO
