if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Top10_GetMetros]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Top10_GetMetros]
GO




CREATE PROCEDURE dbo.Admin_Top10_GetMetros

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select	metroareaid as Metro_Area_ID 
from	MetroAreaVW 
where	toptenlist = 1
GO

GRANT EXECUTE ON [Admin_Top10_GetMetros] TO ExecuteOnlyRole

GO
