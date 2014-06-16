if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DFFDailySummaryRIDStatsHoldingInsert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DFFDailySummaryRIDStatsHoldingInsert]
GO
/*	
	Procedure to insert a row into DFFDailySummaryRIDStatsHolding table
*/
CREATE PROCEDURE dbo.DFFDailySummaryRIDStatsHoldingInsert
( 		
		 @WebRID int
		,@TotalDffs int
		,@Cat_1 int
		,@Cat_4 int
		,@Cat_5 int
		,@Cat_6 int
		,@Cat_7 int
		,@Cat_8 int
		,@Cat_9 int
		,@Cat_10 int
		,@Cat_11 int
		,@Cat_13 int
		,@Cat_14 int
		,@Cat_16 int
		,@Cat_17 int
		,@Cat_18 int
		,@BlackListFlag	bit 			
)
AS
SET NOCOUNT ON
				
INSERT INTO [dbo].[DFFDailySummaryRIDStatsHolding]
            (
			 WebRID
			,TotalDffs 
			,Cat_1 
			,Cat_4 
			,Cat_5 
			,Cat_6 
			,Cat_7 
			,Cat_8 
			,Cat_9 
			,Cat_10 
			,Cat_11 
			,Cat_13 
			,Cat_14 
			,Cat_16 
			,Cat_17 
			,Cat_18 
			,BlackListFlag
			)
     VALUES
           ( 
			 @WebRID
			,@TotalDffs
			,@Cat_1
			,@Cat_4
			,@Cat_5
			,@Cat_6
			,@Cat_7
			,@Cat_8
			,@Cat_9
			,@Cat_10
			,@Cat_11
			,@Cat_13
			,@Cat_14
			,@Cat_16
			,@Cat_17
			,@Cat_18
			,@BlackListFlag
			)
           
GO

GRANT EXECUTE ON [dbo].[DFFDailySummaryRIDStatsHoldingInsert] TO ExecuteOnlyRole

GO

