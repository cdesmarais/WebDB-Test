if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantIncentive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantIncentive]
GO

CREATE PROCEDURE dbo.DNRestaurantIncentive
 As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--****************************
--** Results must be ordered
--** Ordering is done so that website can build an index
--****************************
select		i.rid, i.incentiveday, i.incentiveID, i.startDate, i.EndDate, i.starttime, i.endtime, i.amount, i.LastMinutePopThresholdTime
from		IncentiveVW i
INNER JOIN	Restaurant r
on			r.RID=i.rid
and			r.RestStateID != 4 --** Do not include inactive restaurnts
where	active = 1
	and enddate >= getdate() - 1  -- One day back to ensure no data is lost due to Server to local time conversion

-- Field RID is ambiguous without table variable qualifier (r.rid).
-- Under SQL Server 2008, if compatibility level < 100, this code fails to load.
order by r.rid, incentiveday, i.LastMinutePopThresholdTime

go


GRANT EXECUTE ON [DNRestaurantIncentive] TO ExecuteOnlyRole

GO
