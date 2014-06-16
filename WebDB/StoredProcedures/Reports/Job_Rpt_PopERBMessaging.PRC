IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[Job_RPT_POPERBMessaging]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
	DROP PROCEDURE [dbo].[Job_RPT_POPERBMessaging]
GO

CREATE PROCEDURE dbo.Job_RPT_POPERBMessaging
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select 		Rest.RName,
			Rest.RID,
			Ma.MetroAreaName,
			Case when I.Active = 1 and I.EndDate > getdate() then 'Y' else 'N' end 'POP Status'
from 		RestaurantVW Rest
inner join 	NeighborhoodVW N 
on 			Rest.NeighborhoodID = N.NeighborhoodID
inner join 	MetroAreaVW MA 
on 			N.MetroAreaID = MA.MetroAreaID
inner join	
			(select		ValueID, 
						Max(Inc.IncentiveID) 'MaxIncentiveID'  -- ensure last row get picked
			from 		ValueLookupIDList V
			inner join 	Incentive Inc
			on 			V.ValueID = Inc.RID
			where		V.LookUpID = 21   -- DIP_ERB_MESSAGING
			group by	ValueID
) PEM
on 			Rest.RID = PEM.ValueID
inner join	Incentive I
on 			Rest.RID = I.RID
and			I.IncentiveID = PEM.MaxIncentiveID
group by 	Rest.RName,
			Rest.RID,
			Ma.MetroAreaName,
			Case when I.Active = 1 and I.EndDate > getdate() then 'Y' else 'N' end
order by	Rest.RID


GO


GRANT EXECUTE ON [Job_RPT_POPERBMessaging] TO ExecuteOnlyRole

GO