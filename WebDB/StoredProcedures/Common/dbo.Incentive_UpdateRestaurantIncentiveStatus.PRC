if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_UpdateRestaurantIncentiveStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_UpdateRestaurantIncentiveStatus]
GO


CREATE procedure [dbo].[Incentive_UpdateRestaurantIncentiveStatus]
(
	@RID int, 
	@IncHistID int,
	@DIPStatus int, 
	@ContractSignedBy nvarchar(255), 
	@StartDate datetime, 
	@EndDate datetime,
	@ContractSoldBy nvarchar(255)
)

AS

DECLARE @IncResStatusID int
Declare @dCurrentDate datetime


/********************************************************************************
Update a record into Restaurant DIP Status table.  
The following DIPstatus are available and hard coded in this stored procedure
1 - DIP Customer
2 - Not a DIP Customer
3 - DO NOT DIP
*********************************************************************************/

SELECT @IncResStatusID = IncResStatusID from INCENTIVERESTAURANTSTATUS
WHERE RID = @RID and Active = 1

--Insert new information '

INSERT INTO INCENTIVERESTAURANTSTATUS
	(
	RID, 
	IncStatusID, 
	ContractSignedBy, 
	StartDate, 
	EndDate, 
	ActiveIncHistID,
	ContractSoldBy
	)
	Values
	(
		@RID, 
		@DIPStatus, 
		@ContractSignedBy,
		@StartDate, 
		@EndDate,
		@IncHistID,
		@ContractSoldBy
	)

if(@IncResStatusID is not null)
	Begin
	-- Set the old record's active flag to false.
	UPDATE INCENTIVERESTAURANTSTATUS 
		SET Active = 0, 
		DeActiveIncHistId = @IncHistID 
	WHERE IncResStatusID = @IncResStatusID
	AND RID = @RID
End

GO

GRANT EXECUTE ON [Incentive_UpdateRestaurantIncentiveStatus] TO ExecuteOnlyRole

GO
