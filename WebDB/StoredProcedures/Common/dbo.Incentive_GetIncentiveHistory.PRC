if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_GetIncentiveHistory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_GetIncentiveHistory]
GO

CREATE Procedure [dbo].[Incentive_GetIncentiveHistory]
(
	@RID int
)

AS

/***********************************************************************************
Purpose: This stored procedure will get history of the dip changes happened over a period of time. 
These changes can include
1. Changes to DIP Slots (Could increase number of slots or decrease or modify times for existing slots)
2. Start and End Date for DIP may change. 
3. If the restaurant is opted out of dip program by changing the status to Not a dip customer or Do Not DIP
Under these three kinds of changes we log a history and this history data is pulled using this procedure. 

Approach:

This stored proc retrieves data in the following order:
1. Pulls active records under Incentive Table for corresponding History ID. As part of this process it 
   excludes records that involve only date changes and dip information remains unchanged.
2. Pulls deactivated records under Incentive Table for corresponding history id. Here it excludes records that are marked as 'DIP Created' because every time when status
  changes from DIP Customer to NOT A DIP CUSTOMER, We deactivate the records internally and need not be shown as per history view on UI. Because, We have to show only one record as 'DIP Cancelled'
3. Pulls records that are marked as DIP Cancelled and Date Modified under History Table. 
************************************************************************************/

Declare @tblHistory table 
(
	IncHistID int,
	IncentiveID int, 
	RID int,
	CreateDate datetime,
	IncentiveDayID int,
	IncentiveDay nvarchar(100),
	Status nvarchar(100),
	SignedBy nvarchar(255),
	ChangedBy nvarchar(255), 
	Dummy1 int, 
	Dummy2 int, 
	DateModified datetime,
	StartTime datetime, 
	EndTime datetime,
    DraftSubmitDate datetime,
    ContractEffectiveDate datetime,
    ContractSoldBy nvarchar(255) 
)

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
1. Pulls active records under Incentive Table for corresponding History ID. As part of this process it 
   excludes records that involve only date changes and dip information remains unchanged.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
--Insert created, modifed, increased records
INSERT INTO @tblHistory
(
	IncHistID, 
	RID,
	CreateDate,
	IncentiveDayID,
	IncentiveID,
	IncentiveDay,
	Status,
	SignedBy,
	ChangedBy, 
	Dummy1, 
	StartTime, 
	EndTime,
    DraftSubmitDate,
    ContractEffectiveDate,
    ContractSoldBy 
)
   SELECT A.IncHistID, A.RID, A.CreateDate, I.IncentiveDay, I.IncentiveID, ds.DSchName, IHS.Status, A.SignedBy, 
	A.ChangedBy, 2 type, I.StartTime, I.EndTime
    ,A.DraftSubmitDate
    ,A.ContractEffectiveDate
    ,A.ContractSoldBy
	FROM IncentiveHistory A
	INNER JOIN Incentive I
	ON A.IncHistID = I.ActiveIncHistID
	INNER JOIN DaySchedule Ds ON
	ds.DSchID = I.IncentiveDay
	LEFT JOIN IncentiveHistoryStatus IHS
	ON A.IncHistStatusID = IHS.IncHistStatusID
	Where I.RID = @RID 
	AND A.IncHistStatusID <> 7
	and I.LastMinutePopThresholdTime IS NULL
	
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
2.Pulls deactivated records under Incentive Table for corresponding history id. Here it excludes records that are marked as 'DIP Created' because every time when status
changes from NOT A DIP CUSTOMER to DIP Customer, We deactivate the records and create them again and these deactivated and need not be shown as per history view on UI. 
Similary when only Start Date or end date is modified for dip, we modify all the records to depict the new dates. Therefore, deactivated records for date modified need
to be suppressed. 
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
INSERT INTO @tblHistory
(
	IncHistID, 
	RID,
	CreateDate,
	IncentiveDayID,
	IncentiveID,
	IncentiveDay,
	Status,
	SignedBy,
	ChangedBy, 
	Dummy1, 
	StartTime, 
	EndTime, 
    DraftSubmitDate,
    ContractEffectiveDate,
    ContractSoldBy 
)
   	SELECT D.IncHistID, D.RID, D.CreateDate, I.IncentiveDay, I.IncentiveID, ds.DSchName, IHS.Status, D.SignedBy, D.ChangedBy,
	 1 type, null, null
    ,D.DraftSubmitDate
    ,D.ContractEffectiveDate
    ,D.ContractSoldBy
	FROM IncentiveHistory D
	INNER JOIN Incentive I
	ON D.IncHistID = I.DeActiveIncHistID
	INNER JOIN DaySchedule Ds ON
	ds.DSchID = I.IncentiveDay
	LEFT JOIN IncentiveHistoryStatus IHS
	ON D.IncHistStatusID = IHS.IncHistStatusID
	--This filters record that are deleted as part of Cancel and date modified process - These records are marked internally as deleted and 
	-- need not be shown on UI
	WHERE (D.IncHistStatusID <> 3 AND D.IncHistStatusID <> 7)
		  --The condition below filters records that have deactivated id but no corresponding activateid for a day
		  -- We apply this filter to discard records that are just modified and consider only removed or deleted records.
		  AND Not Exists(select t.IncHistID from @tblHistory t where t.IncHistID = D.IncHistID AND I.IncentiveDay = t.IncentiveDayID)
		  AND I.RID = @RID 
		  and I.LastMinutePopThresholdTime IS NULL

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
3. Pulls records that are marked as DIP Cancelled and Date Modified under History Table. 
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

INSERT INTO @tblHistory
(
	IncHistID, 
	RID,
	CreateDate,
	Status,
	SignedBy,
	ChangedBy, 
	Dummy1, 
	Dummy2, 
	DateModified,
    DraftSubmitDate,
    ContractEffectiveDate,
    ContractSoldBy 
)
SELECT C.IncHistID, C.RID, C.CreateDate, IHS.Status, C.SignedBy, C.ChangedBy, 0 type, 0 type, C.CreateDate
    ,C.DraftSubmitDate
    ,C.ContractEffectiveDate
    ,C.ContractSoldBy
FROM INCENTIVEHISTORY C
INNER JOIN IncentiveHistoryStatus IHS
ON C.IncHistStatusID = IHS.IncHistStatusID
WHERE c.RID = @RID 
	AND (C.IncHistStatusID = 5 OR c.IncHistStatusID = 7)

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
4. Retrieve Data from temporary table
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

Select
	IncHistID,
	IncentiveID, 
	RID,
	CreateDate,
	IncentiveDayID,
	IncentiveDay,
	Status,
	SignedBy,
	ChangedBy, 
	Dummy1, 
	Dummy2, 
	DateModified,
	StartTime, 
	EndTime,
    DraftSubmitDate,
    ContractEffectiveDate,
    ContractSoldBy 
From @tblHistory ORDER BY CreateDate DESC, IncHistID DESC, IncentiveDayID ASC

Go

GRANT EXECUTE ON [Incentive_GetIncentiveHistory] TO ExecuteOnlyRole

Go
