if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExtractDIPInventory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ExtractDIPInventory]
GO

CREATE PROCEDURE dbo.ExtractDIPInventory

AS

set nocount on
set transaction isolation level read uncommitted

Declare @IncentiveData table(
RID int, 
Rname nvarchar(255),
MetroAreaName nvarchar(255),
IncentiveDay nvarchar(20),
ContractSoldBy nvarchar(255),
Dipcount11AMTo1PM int,
Dipcount5PMTo10PM int
)

/*
NOTE: We add 15 minutes to End Time in the incentive table to comply with DIP logic in ConsumerWebSite.
*/
Declare @dtStartRange11AM datetime,
		@dtEndRange1PM datetime,
		@dtStartRange5PM datetime,
		@dtEndRange10PM datetime
		

--set start and end times for 11-1PM time slot
Set @dtStartRange11AM = '1900-01-01 11:00:00.000'
set @dtEndRange1PM = '1900-01-01 13:15:00.000'


--set start and end times for 5PM-10PM time slot
Set @dtStartRange5PM = '1900-01-01 17:00:00.000'
set @dtEndRange10PM = '1900-01-01 22:15:00.000'



/*SCENARIOS
1---Start and End times between the time ranges 5PM to 10 PM.
2---StartTime is between the time range and End time is outside of time range 9PM to 10:30PM
3---EndTime falls in Time Range Ex: 4PM to 6PM then we want to cover 5PM to 6PM
4---Start and End Times include the set time range (Ex: 4PM to 11PM)
*/

INSERT INTO @IncentiveData
(
	RID, 
	Rname,
	MetroAreaName,
	IncentiveDay,
	ContractSoldBy,
	Dipcount11AMTo1PM,
	Dipcount5PMTo10PM
)
select * from
(
	SELECT R.RID, 
		   R.Rname, 
		   M.metroAreaName, 
		   I.IncentiveDay, 
		   IR.ContractSoldBy, --This field need to be set once added as part of WR7. It also needs to be added as part of group by condition
		   sum(
				CASE WHEN (I.StartTime >=@dtStartRange11AM AND i.EndTime <=@dtEndRange1PM)  --SCENARIO - 1
						  THEN DateDiff(mi, i.StartTime, i.EndTime)/15
					 WHEN (I.StartTime >= @dtStartRange11AM AND I.StartTime <= @dtEndRange1PM AND I.EndTime > @dtEndRange1PM)--SCENARIO - 2
						  THEN DateDiff(mi, i.StartTime, @dtEndRange1PM)/15
					 WHEN (I.EndTime >= @dtStartRange11AM AND I.EndTime <= @dtEndRange1PM) --SCENARIO - 3
						  THEN DateDiff(mi, @dtStartRange11AM, I.EndTime)/15
					 WHEN (I.StartTime < @dtStartRange11AM AND I.EndTime > @dtEndRange1PM) --SCENARIO - 4
						  THEN DateDiff(mi, @dtStartRange11AM, @dtEndRange1PM)/15				 
					 ELSE 0
				END
			) as Dipcount11AMTo1PM,
		   sum(
				CASE WHEN (I.StartTime >=@dtStartRange5PM AND i.EndTime <=@dtEndRange10PM)  --SCENARIO - 1
						  THEN DateDiff(mi, i.StartTime, i.EndTime)/15
					 WHEN (I.StartTime >= @dtStartRange5PM AND I.StartTime <= @dtEndRange10PM AND I.EndTime > @dtEndRange10PM)--SCENARIO - 2
						  THEN DateDiff(mi, i.StartTime, @dtEndRange10PM)/15
					 WHEN (I.EndTime >= @dtStartRange5PM AND I.EndTime <= @dtEndRange10PM) --SCENARIO - 3
						  THEN DateDiff(mi, @dtStartRange5PM, I.EndTime)/15
					 WHEN (I.StartTime < @dtStartRange5PM AND I.EndTime > @dtEndRange10PM) --SCENARIO - 4
						  THEN DateDiff(mi, @dtStartRange5PM, @dtEndRange10PM)/15				 
					 ELSE 0
				END
			) as Dipcount5PMTo10PM  
	FROM IncentiveVW I
	INNER JOIN IncentiveRestaurantStatus IR
	ON I.RID = IR.RID
	INNER JOIN RestaurantVW r
	ON I.RID = R.RID
	INNER JOIN NeighborhoodVW n 
	ON R.NeighborhoodID = n.NeighborhoodID
	INNER JOIN MetroAreaVW m 
	ON n.MetroAreaID = m.MetroAreaID
	WHERE I.Active = 1
	AND I.LastMinutePopThresholdTime IS NULL
	AND IR.Active = 1
	AND M.MetroAreaID <> 1 and M.Active = 1
	GROUP BY R.RID, R.Rname, M.metroAreaName, I.IncentiveDay, IR.ContractSoldBy
) dip
where (dip.Dipcount11AMTo1PM > 0 OR dip.Dipcount5PMTo10PM > 0) 

SELECT RID,
	   RName as RestaurantName,
	   MetroAreaName,
	   ContractSoldBy,
	    Max(Case WHEN IncentiveDay = 2 THEN Dipcount11AMTo1PM
			 ELSE 0 End) as 'Monday 11AM - 1PM',  
	   Max(Case WHEN IncentiveDay = 3 THEN Dipcount11AMTo1PM
			 ELSE 0 End) as 'Tuesday 11AM - 1PM', 
	   Max(Case WHEN IncentiveDay = 4 THEN Dipcount11AMTo1PM
			 ELSE 0 End) as 'Wednesday 11AM - 1PM', 
		Max(Case WHEN IncentiveDay = 5 THEN Dipcount11AMTo1PM
			 ELSE 0 End) as 'Thursday 11AM - 1PM', 
		Max(Case WHEN IncentiveDay = 6 THEN Dipcount11AMTo1PM
			 ELSE 0 End) as 'Friday 11AM - 1PM',
		Max(Case WHEN IncentiveDay = 7 THEN Dipcount11AMTo1PM
			 ELSE 0 End) as 'Saturday 11AM - 1PM',
		Max(Case WHEN IncentiveDay = 1 THEN Dipcount11AMTo1PM
			 ELSE 0 End) as 'Sunday 11AM - 1PM', 
	   Max(Case WHEN IncentiveDay = 2 THEN Dipcount5PMTo10PM
			 ELSE 0 End) as 'Monday 5PM - 10PM',  
	   Max(Case WHEN IncentiveDay = 3 THEN Dipcount5PMTo10PM
			 ELSE 0 End) as 'Tuesday 5PM - 10PM', 
	   Max(Case WHEN IncentiveDay = 4 THEN Dipcount5PMTo10PM
			 ELSE 0 End) as 'Wednesday 5PM - 10PM', 
		Max(Case WHEN IncentiveDay = 5 THEN Dipcount5PMTo10PM
			 ELSE 0 End) as 'Thursday 5PM - 10PM', 
		Max(Case WHEN IncentiveDay = 6 THEN Dipcount5PMTo10PM
			 ELSE 0 End) as 'Friday 5PM - 10PM' ,
		Max(Case WHEN IncentiveDay = 7 THEN Dipcount5PMTo10PM
			 ELSE 0 End) as 'Saturday 5PM - 10PM' ,
		Max(Case WHEN IncentiveDay = 1 THEN Dipcount5PMTo10PM
			 ELSE 0 End) as 'Sunday 5PM - 10PM',
		Sum(Dipcount11AMTo1PM) as 'Total 11AM - 1PM',
		Sum(Dipcount5PMTo10PM) as 'Total 5PM - 10PM',
		(Sum(Dipcount11AMTo1PM)+ Sum(Dipcount5PMTo10PM)) as Total
From @IncentiveData
Group By RID, RName, MetroAreaName, ContractSoldBy
Order by MetroAreaName, RName


Go

GRANT EXECUTE ON [ExtractDIPInventory] TO ExecuteOnlyRole
GRANT EXECUTE ON [ExtractDIPInventory] TO DTR_User
GO





