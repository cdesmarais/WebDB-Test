if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExtranetIncentiveViewRestsByMacro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ExtranetIncentiveViewRestsByMacro]
GO


CREATE PROCEDURE dbo.ExtranetIncentiveViewRestsByMacro
(
  @Metro_ID int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select 
distinct r.RID
			, r.RName
			,CASE WHEN ((r.RestStateID = 1 AND r.IsReachable = 1) or (r.Allotment = 1) AND(r.RestStateID = 1))
				THEN 1 ELSE 0 END AS RestaurantState
			,neighborhood.MacroID
			,mn.MacroName
			,SortOrder
from		DaySchedule
inner join	incentive 
on			DaySchedule.DSchID = Incentive.IncentiveDay
inner join	restaurantVW r
on			r.RID = incentive.RID
inner join	neighborhood
on			neighborhood.NeighborhoodID = r.NeighborhoodID
inner join	MacroNeighborhoodAVW mn
on			neighborhood.MacroID = mn.MacroID
and			r.LanguageId = mn.LanguageID
where		DSchID in (1,2,3,4,5,6,7) 
and			neighborhood.MetroAreaID = @Metro_ID 
and			incentive.active = 1 
and			Incentive.LastMinutePopThresholdTime IS NULL
and			EndDate >= getdate()-1
and			r.RestStateID IN (1,5,6,13)
Order By	SortOrder
			,mn.MacroName
			,r.RName
			,r.RID desc


GO

GRANT EXECUTE ON [ExtranetIncentiveViewRestsByMacro] TO ExecuteOnlyRole

GO
