--
-- dbo.JobClear_RestaurantCoverCountsStaging.PRC
-- Truncates the RestaurantCoverCountsStaging table
--

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobClear_RestaurantCoverCountsStaging]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobClear_RestaurantCoverCountsStaging]
GO

-- Create the proc
CREATE PROCEDURE dbo.JobClear_RestaurantCoverCountsStaging

AS

DELETE FROM RestaurantCoverCountsStaging
GO

-- Ensure proper permissions
GRANT EXECUTE ON [JobClear_RestaurantCoverCountsStaging] TO ExecuteOnlyRole

GO
