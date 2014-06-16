if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Job_Appetite_Stimulus_Plan]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Job_Appetite_Stimulus_Plan]
GO

CREATE Procedure dbo.Job_Appetite_Stimulus_Plan  AS

set transaction isolation level read uncommitted
-- insert into PointsAdjustment table the Reservations qualified the Promotion program

DECLARE	@promoID		INT
set		@promoID		= 329					-- OpenTable Appetite Stimulus Plan

declare @EventStartDate datetime
declare @EventEndDate datetime

select	@EventStartDate = EventStartDate,
		@EventEndDate = EventEndDate
from	dbo.PromoPages	pp
where      pp.PromoID = @promoID

INSERT INTO dbo.PointsAdjustment (
	ResID
	,CustID
	,CallerID
	,AdjustmentAmount
	,AdjReasonID
	,AdjustmentDate	
) 	

SELECT	r.ResID
		,CASE WHEN r.CallerID IS NULL THEN r.CustID ELSE NULL END AS CustID
		,CASE WHEN r.CallerID IS NOT NULL THEN r.CallerID ELSE NULL END AS CallerID	
		,100 AS AdjustmentAmount				-- Bonus Points: 100
		,30	 AS AdjReasonID						-- Appetite Stimulus Plan Bonus Points
		,GETDATE() AS AdjustmentDate					
FROM	reservationVW		r   
INNER JOIN PromoRests		pr
ON		r.RID = pr.RID
AND		pr.PromoID = @promoID
LEFT JOIN PointsAdjustment  pa
ON	    pa.resID = r.resID
--***	Use of Hardcoded date forces the correct partion to be chosen and makes query more efficient
WHERE	r.shiftDate BETWEEN '2008-11-01' and	'2008-11-30' 
and		r.shiftDate BETWEEN @EventStartDate AND @EventEndDate
AND		r.RStateID IN (2,5,7)					-- seated, assumed seated, seated disputed
AND		r.ReferrerID IN (4681,4684,4702,4705,4699,4723,4747,4708,4711,4687,4696,4690,4717,4726,4729,4735,4738,4741,4744)		
AND	    r.ResPoints = 100						-- only qualified points resos
AND		((pr.Dinner = 1 and convert(nvarchar(12),r.ResTime,114) >= '16:00:00.000')
		 OR	(pr.Lunch =1 and convert(nvarchar(12),r.ResTime,114) < '16:00:00.000'))		
AND		pa.resid IS null
GO


GRANT EXECUTE ON [Job_Appetite_Stimulus_Plan] TO ExecuteOnlyRole

GO




