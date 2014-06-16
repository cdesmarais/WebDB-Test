if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_DeleteIncentive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_DeleteIncentive]
GO

CREATE procedure [dbo].[Incentive_DeleteIncentive]
(
@RID int, 
@IncHistID int,
@IncentiveID int
)
As

--Update existing Incentive Record to turn it to Inactive

UPDATE Incentive
SET Active = 0, 
DeactiveIncHistId = @IncHistID
WHERE IncentiveID = @IncentiveID
AND RID = @RID

GO

GRANT EXECUTE ON [Incentive_DeleteIncentive] TO ExecuteOnlyRole

GO
