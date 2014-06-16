if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DFFDailySummaryRIDStatsHoldingDelete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DFFDailySummaryRIDStatsHoldingDelete]
GO
/*	
	Procedure to delete all rows from DFFDailySummaryRIDStatsHolding table
*/
CREATE PROCEDURE dbo.DFFDailySummaryRIDStatsHoldingDelete 
AS
SET NOCOUNT ON
				
delete from [dbo].[DffDailySummaryRIDStatsHolding]
           
GO

GRANT EXECUTE ON [dbo].[DFFDailySummaryRIDStatsHoldingDelete] TO ExecuteOnlyRole

GO

