if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheRestIncentiveDaySuppress]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheRestIncentiveDaySuppress]
GO

CREATE PROCEDURE dbo.ObjectCacheRestIncentiveDaySuppress
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--*******************************
--** Retrieve all Days in the future (go back one day to be safe -- this is to ensure that all local times are present)
--*******************************
SELECT		i.rid, 
			i.SuppressedDate
FROM		IncentiveSuppressDay i
INNER JOIN	IncentiveRestaurantStatus irs 
ON			irs.RID = i.RID 
AND			irs.Active = 1
WHERE		irs.IncStatusID = 1
AND			i.active = 1
AND			i.SuppressedDate > getdate() - 1


GO


GRANT EXECUTE ON [dbo].[ObjectCacheRestIncentiveDaySuppress] TO ExecuteOnlyRole

GO
