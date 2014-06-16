if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheRestaurantIncentive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheRestaurantIncentive]
GO

CREATE PROCEDURE dbo.ObjectCacheRestaurantIncentive
 As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		i.rid, 
			i.incentiveday, 
			i.incentiveID, 
			i.startDate, 
			i.EndDate, 
			i.starttime, 
			i.endtime, 
			i.amount, 
			i.LastMinutePopThresholdTime
FROM		IncentiveVW i -- NOTE this view is not for localization; this view is for managing active status
INNER JOIN	Restaurant r
ON			r.RID=i.rid
AND			r.RestStateID != 4 --** Do not include inactive restaurnts
WHERE		active = 1
AND			enddate >= getdate() - 1  -- One day back to ensure no data is lost due to Server to local time conversion



GO


GRANT EXECUTE ON [ObjectCacheRestaurantIncentive] TO ExecuteOnlyRole

GO
