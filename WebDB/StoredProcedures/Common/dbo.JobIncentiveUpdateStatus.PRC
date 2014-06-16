if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobIncentiveUpdateStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobIncentiveUpdateStatus]
GO
CREATE PROCEDURE dbo.JobIncentiveUpdateStatus

AS

--****************************************************************
-- Date: 01/16/2007
-- By: Nagesh Challapalli
-- Purpose:This script verifies restaurants whose DIP Status has expired (whose end date has past current restaurant's local time)
-- and logs a history under IncentiveHistory Table and updates the status of restaurant to 'NOT A DIP Customer'
-- Once updated, the restaurant's dip times stop showing on the Consumer Website.
--*****************************************************************

DECLARE @RID int,
		@StartDate datetime,
		@EndDate datetime,
		@ContractSignedBy nvarchar(255),
		@IncHistID int,
		@ContractSoldBy nvarchar(255),
        @ContractEffectiveDate datetime


DECLARE IncRestCursor CURSOR FOR
SELECT IRS.RID, IRS.StartDate, IRS.EndDate, IRS.ContractSignedBy, IRS.ContractSoldBy, IRS.ContractEffectiveDate 
FROM IncentiveRestaurantStatus IRS
INNER JOIN Restaurant R ON IRS.RID = R.RID
INNER JOIN TimezoneVW t on r.TZID = t.TZID
--Here we add a day to end date because we include end date valid for dip and consider expired past end date.
WHERE t.CurrentLocalTime > dbo.fGetDatePart(IRS.Enddate)+1
AND IRS.Active = 1
AND IRS.IncStatusID = 1 -- Verify the status as DIP Customer.


OPEN IncRestCursor

FETCH NEXT FROM IncRestCursor
INTO @RID, @StartDate, @Enddate, @ContractSignedBy, @ContractSoldBy, @ContractEffectiveDate

WHILE @@FETCH_STATUS = 0
BEGIN
BEGIN TRANSACTION 
	--Insert IncentiveHistory Record.Here pass DraftsubmitDate as null.
    --When draftSubmitdate parameter is null then the stored procedure Incentive_InsertIncentiveHistory 
    --internally set this date as the current date.
	
	Exec Incentive_InsertIncentiveHistory @RID, 'POP Cancelled', @ContractSignedBy, null, null, null, null,
     'Automatic', @ContractSoldBy, @IncHistID OUTPUT, null, @ContractEffectiveDate 
	
	IF @@Error <> 0  
       goto error

	-- Insert the record. set Restaurant's dip status as 'Not a DIP Customer (id = 2)' 
	Exec Incentive_UpdateRestaurantIncentiveStatus1 @RID, @IncHistID, 2, @ContractSignedBy, @StartDate, @EndDate,
     @ContractSoldBy, @ContractEffectiveDate
	
	IF @@Error <> 0  
      goto error

COMMIT TRANSACTION 

FETCH NEXT FROM IncRestCursor
INTO @RID, @StartDate, @Enddate, @ContractSignedBy, @ContractSoldBy, @ContractEffectiveDate
END

CLOSE IncRestCursor
DEALLOCATE IncRestCursor

error:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 

Go


GRANT EXECUTE ON [JobIncentiveUpdateStatus] TO ExecuteOnlyRole

GO
