if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_UpdateSuppressedDays]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_UpdateSuppressedDays]
GO



CREATE procedure [dbo].[Incentive_UpdateSuppressedDays]
(
	@RID int, 
	@IncSuppressID int, 
	@IncHistID int
)
AS

Update IncentiveSuppressDay
SET Active = 0, 
DeActiveIncHistID = @IncHistID
WHERE IncSuppressID = @IncSuppressID
AND RID = @RID

Go

GRANT EXECUTE ON [Incentive_UpdateSuppressedDays] TO ExecuteOnlyRole

Go

