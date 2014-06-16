IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DNNagiosGetOfflineRatioForEMHGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[DNNagiosGetOfflineRatioForEMHGroup]
GO


CREATE Procedure [dbo].[DNNagiosGetOfflineRatioForEMHGroup]
AS

DECLARE @TotalCount FLOAT = 0
DECLARE @OfflinePercentage FLOAT = 0
DECLARE @FRNCount FLOAT = 0
DECLARE @NotReachableCount FLOAT = 0
DECLARE	@Status     INT				= 0
DECLARE	@Message    VARCHAR(8000)	= 'No RIDs in CacheServerERBGroup'

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT			@TotalCount = COUNT(1),
				@FRNCount = ISNULL(SUM(CASE WHEN a.RestStateID = 16 THEN 1 ELSE 0 END), 0),
				@NotReachableCount = ISNULL(SUM(CASE WHEN a.IsReachable = 0 THEN 1 ELSE 0 END), 0)
FROM			Restaurant	a
INNER JOIN		ErbRestaurant b
ON				a.RID = b.RID
INNER JOIN		CacheServerERBGroup c
ON				b.CacheServerERBGroupID = c.CacheServerERBGroupID
WHERE			c.GroupName LIKE '%EMH'
AND				a.RestStateID IN (1, 13, 16)-- Pick Active Restaurants, some might be FRN
AND				a.RestaurantType IN ('E', 'G')

--Avoid Divide by zero error
IF (@TotalCount > 0)
BEGIN
	SET @OfflinePercentage = ((@FRNCount + @NotReachableCount)/@TotalCount) * 100
	SET	@Message = 'Offline RID Percentage is ' + CAST (CEILING(@OfflinePercentage) AS VARCHAR(10)) + '%' 
					+ ' Total: ' + CAST(@TotalCount AS VARCHAR)
					+ ' FRN: ' + CAST(@FRNCount AS VARCHAR)
					+ ' NotReachable: ' + CAST(@NotReachableCount AS VARCHAR) 
					
END

--Set Status based on defined thresholds
SET	@Status	= CASE 
				WHEN (@OfflinePercentage) > 10.0 THEN 2 -- Critical
				WHEN (@OfflinePercentage) BETWEEN 5.0 AND 10.0 THEN 1 -- Warning
				ELSE 0 -- Green
			  END

--Result set for Nagios
SELECT  @Status							AS [Status],
        REPLACE(@Message, ' ', '_') 	AS ErrorMessage

GO

        
GRANT EXECUTE ON [DNNagiosGetOfflineRatioForEMHGroup] TO ExecuteOnlyRole
GRANT EXECUTE ON [DNNagiosGetOfflineRatioForEMHGroup] TO MonitorUser        
GO