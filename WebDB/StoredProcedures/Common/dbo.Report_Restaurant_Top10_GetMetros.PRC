if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Restaurant_Top10_GetMetros]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Restaurant_Top10_GetMetros]
GO

CREATE PROCEDURE dbo.Report_Restaurant_Top10_GetMetros

AS
SET NOCOUNT ON
set transaction isolation level read uncommitted

Select MetroAreaID as Metro_Area_ID
,MetroAreaName as Name
from MetroAreaVW 
where toptenlist = 1
and MetroAreaID <> 1

GO


GRANT EXECUTE ON [Report_Restaurant_Top10_GetMetros] TO ExecuteOnlyRole

GO
