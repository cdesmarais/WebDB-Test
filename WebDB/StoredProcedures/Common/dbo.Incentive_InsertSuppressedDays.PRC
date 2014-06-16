
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_InsertSuppressedDays]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_InsertSuppressedDays]
GO


CREATE procedure [dbo].[Incentive_InsertSuppressedDays]
(
	@RID int, 
	@SuppressedDate datetime, 
	@IncHistID int
)
AS

Insert into IncentiveSuppressDay
(
	RID, 
	SuppressedDate, 
	ActiveIncHistID
)
values
(
	@RID, 
	@SuppressedDate, 
	@IncHistID
)

Go

GRANT EXECUTE ON [Incentive_InsertSuppressedDays] TO ExecuteOnlyRole

Go

