if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_VerifyIncentiveHistory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_VerifyIncentiveHistory]
GO

CREATE procedure [dbo].[Incentive_VerifyIncentiveHistory]
(
	@RID int,
	@LastIncHistID int
)
As

/*********************************************************************
This Procedure checks if there are any changes made from last save to this table. 
Compares last history id value as parameter with lastest history record from Incentive History Table.
If both the values match then no records have been modified. If not then we return 0 indicating data change.
*********************************************************************/

Declare @MaxIncHistID int

SELECT @MaxIncHistID = Max(IncHistID)
FROM IncentiveHistory
WHERE RID = @RID

--
If(@LastIncHistID <> @MaxIncHistId)
	return 0
else
	return 1

Go

GRANT EXECUTE ON [Incentive_VerifyIncentiveHistory] TO ExecuteOnlyRole


GO

