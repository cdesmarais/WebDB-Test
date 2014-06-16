--
-- dbo.JobPopulateRestaurantCoverCounts.PRC
-- Counts standard resos for rids and returns RID, count, and time calculated
--

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobPopulateRestaurantCoverCounts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobPopulateRestaurantCoverCounts]
GO

-- Create the proc
CREATE PROCEDURE dbo.JobPopulateRestaurantCoverCounts

AS

-- everything in a transaction
BEGIN TRANSACTION

	BEGIN TRY
		-- Clear out the target table
		DELETE FROM RestaurantCoverCounts
		
		-- Populate the target table from the staging table
		INSERT INTO RestaurantCoverCounts (RID, TotalSeatedStandardCovers, LastComputedDate)
		  SELECT	RID,
					TotalSeatedStandardCovers,
					LastComputedDate
		  FROM		RestaurantCoverCountsStaging
	END TRY
	BEGIN CATCH
		-- error occurred
		ROLLBACK TRANSACTION
		DECLARE @Err NVARCHAR(2000)
		SET @Err = ERROR_MESSAGE()
		RAISERROR (@Err, 16, 1)
		RETURN
	END CATCH

 -- AOK
 COMMIT TRANSACTION

GO


-- Ensure proper permissions
GRANT EXECUTE ON [JobPopulateRestaurantCoverCounts] TO ExecuteOnlyRole

GO
