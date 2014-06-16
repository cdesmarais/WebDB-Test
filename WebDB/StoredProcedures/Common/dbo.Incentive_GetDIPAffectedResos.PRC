if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_GetDIPAffectedResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_GetDIPAffectedResos]

GO

CREATE PROCEDURE [dbo].[Incentive_GetDIPAffectedResos](
                @RID           INT,
                @sSunday       NVARCHAR(4000),
                @sMonday       NVARCHAR(4000),
                @sTuesday      NVARCHAR(4000),
                @sWednesday    NVARCHAR(4000),
                @sThursday     NVARCHAR(4000),
                @sFriday       NVARCHAR(4000),
                @sSaturday     NVARCHAR(4000),
                @dOldStartDate datetime,
                @dOldEndDate   datetime,
                @dNewStartDate datetime,
                @dNewEndDate   datetime
)
AS

/********************************************************************************************************
Purpose: Get all dip affected Resos for a restaurant. Changes made to dip slots or changes made to start and end date for 
a restaurant may affect resos as those resos will no longer be honored with 1000 points. So this proce will pull out such resos
for a given restaurant. 

Approach: 
1. Create a datatable that will have affected timeslots information segregated by day of week
2. Based on various conditions like any date changes along with time slot changes, pull information from Reservation Table.
   If there are no date changes, then just pull data for affected slots. 
3. Join the above information with other reservation tables to get Rest Ref and Reservation State infomration.

Parameters: The parameters for this stored procedure are comma dilimited times for each day of week and the start and end dates (Both old and 
new). Here is a sample of the timeslot string
'2^17:00, 17:15, 17:30' --> Here 2 indicates day of week which is monday. 
********************************************************************************************************/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

  DECLARE  @bDateModified BIT
 
  DECLARE  @dCurrentDate DATETIME
  
  --SET @dCurrentDate = dbo.fGetDatePart(getdate())
--set current date to restaurant's local current date.
  exec procRestaurantGetCurrentLocalTime @RID,  @dCurrentDate output

  SET @dCurrentDate = dbo.fGetDatePart(@dCurrentDate)
  
  SET @bDateModified = 0
  


  --Create temporary Reservation Table---
  DECLARE @tblDIPAffectedResos TABLE (
    Reservation_ID     INT,
    Shift_Date         DATETIME,
    Reservation_Time   DATETIME,
    RID                INT,
    Party_size         INT,
    Date_Made          DATETIME,
    ReservationStateID INT,
    ConfNumber         INT)

  -- Create temporary dipslot table which contains dayofweek and timeslot
  DECLARE @tblDIPSlots TABLE (
    DayOfWeek INT,
    TimeSlot  datetime)


  ---------------------***Convert timeslots into a data table***-----------------------------------------------------. 
Insert into @tblDIPSlots(DayofWeek,TimeSlot)(select DayofWeek, TimeSlot from dbo.fIncentiveTimeSlotStrToTab(@sSunday, '^', ','))
Insert into @tblDIPSlots(DayofWeek,TimeSlot)(select DayofWeek, TimeSlot from dbo.fIncentiveTimeSlotStrToTab(@sMonday, '^', ','))
Insert into @tblDIPSlots(DayofWeek,TimeSlot)(select DayofWeek, TimeSlot from dbo.fIncentiveTimeSlotStrToTab(@sTuesday, '^', ','))
Insert into @tblDIPSlots(DayofWeek,TimeSlot)(select DayofWeek, TimeSlot from dbo.fIncentiveTimeSlotStrToTab(@sWednesday, '^', ','))
Insert into @tblDIPSlots(DayofWeek,TimeSlot)(select DayofWeek, TimeSlot from dbo.fIncentiveTimeSlotStrToTab(@sThursday, '^', ','))
Insert into @tblDIPSlots(DayofWeek,TimeSlot)(select DayofWeek, TimeSlot from dbo.fIncentiveTimeSlotStrToTab(@sFriday, '^', ','))
Insert into @tblDIPSlots(DayofWeek,TimeSlot)(select DayofWeek, TimeSlot from dbo.fIncentiveTimeSlotStrToTab(@sSaturday, '^', ','))
---------------------------------------***End***----------------------------------------------------------------------------. 
  

-- if dates have changed then we need to add the special filter.
  IF ((@dNewStartDate <> @dOldStartDate) OR (@dOldEndDate <> @dNewEndDate))
    SET @bDateModified = 1

/*
Scenarios:
1. If only Start Date has been moved to a later date than old start date and dip slots info remain same
2. If only End Date has been moved to a earlier date than old end date and dip slots info remain same
3. If only Start Date has been moved to a later date than old start date and also dip slots info change 
4. If only End Date has been moved to a earlier date than old end date and also dip slots info change  
5. If Start Date has been moved to a later date than old start date, new end date earlier to old end date and dip slots info change
6. If Start Date has been moved to a later date than old start date, new end date earlier to old end date and dip slots info remain same 
7. If start and end dates remain same and Dip slots are modified.
*/

  IF (@bDateModified = 1)
    BEGIN
    --if only start dates have changed
      IF ((@dNewStartDate > @dOldStartDate)  AND (@dOldEndDate = @dNewEndDate))
        BEGIN
             /*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			  Scenario 3 and Scenario 1 are consolidated to single query which returns same data except if dip slots are modified
			  then it adds up the condition to return them.
			  Scenario - 3 
			  When Start date is moved to later date than old start date And DIP Slots have been modified
			  We get   
				1. All Resos from current date to new start date (exclusing startdate(startdate-1))
			  	2. All dip affected resos from new startdate 
			  	
			  Scenario - 1
			  When only Start date is moved to later date than old start date And DIP Slots remain unmodified.
			  We get   
				1. All resos BETWEEN current date to new start date 	
				
			 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
              INSERT INTO @tblDIPAffectedResos
                         (Reservation_ID,
                          Shift_Date,
                          Reservation_Time,
                          RID,
                          Party_size,
                          Date_Made,
                          ReservationStateID,
                          ConfNumber
						  )
              SELECT GR.ResID AS Reservation_ID,
                     GR.ShiftDate AS Shift_Date,
                     GR.ResTime AS Reservation_Time,
                     GR.RID,
                     CASE 
                       WHEN (COALESCE(GR.seatedSize,0) < 1) THEN GR.Partysize
                       ELSE GR.seatedSize
                     END AS Party_size,
                     GR.DateMade AS Date_Made,
                     GR.RStateID AS ReservationStateID,
                     GR.ConfNumber
              FROM   Reservation GR
                     LEFT OUTER JOIN @tblDIPSlots tb
                       ON GR.ResTIme = tb.TimeSlot
                          AND DATEPART(dw,GR.ShiftDate) = tb.DayOfWeek
              WHERE  GR.RID = @RID
                     AND RStateID = 1
                     AND GR.ResPoints = 1000
					 AND (  
							(GR.ShiftDate BETWEEN @dCurrentDate AND @dNewStartDate-1)
							OR (tb.TimeSlot IS NOT NULL 
								AND (GR.ShiftDate > @dNewStartDate)
								)
						 )
        END
      
	  -- if only end dates have changed. 
      ELSE
        IF ((@dNewStartDate = @dOldStartDate)AND (@dNewEndDate < @dOldEndDate))
          BEGIN
          --When end date differ
              /*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			 
			  Scenario 4 and Scenario 2 are consolidated to single query which returns same data except if dip slots are modified
			  then it adds up the condition to return them.
			  
			  Scenario - 4  
			  When end date is moved to earlier date than old end date And DIP Slots have been modified.
			  We get   
				1. DIP Affected Resos BETWEEN current date to new end date
				2. All resos from new end date forward	
			
				Scenario - 2	
				When end date is moved to earlier date than old end date And DIP Slots remain the same.
				We get  
					 1. All resos from new end date forward					
			  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
                          
                INSERT INTO @tblDIPAffectedResos
                           (Reservation_ID,
                            Shift_Date,
                            Reservation_Time,
                            RID,
                            Party_size,
                            Date_Made,
                            ReservationStateID,
                            ConfNumber)
                SELECT   GR.ResID AS Reservation_ID,
                         GR.ShiftDate AS Shift_Date,
                         GR.ResTime AS Reservation_Time,
                         GR.RID,
                         CASE 
							WHEN (COALESCE(GR.seatedSize,0) < 1) THEN GR.Partysize
							ELSE GR.seatedSize
						 END AS Party_size,
                         GR.DateMade AS Date_Made,
                         GR.RStateID AS ReservationStateID,
                         GR.ConfNumber
                FROM     Reservation GR
                         LEFT OUTER JOIN @tblDIPSlots tb
                           ON GR.ResTIme = tb.TimeSlot
                              AND DATEPART(dw,GR.ShiftDate) = tb.DayOfWeek
                WHERE    GR.RID = @RID
                         AND GR.ResPoints = 1000
                         AND GR.RStateID = 1
						 AND (
								   (GR.ShiftDate > @dNewEndDate)
								 OR(
									  tb.TimeSlot IS NOT NULL 
									  AND (GR.ShiftDate BETWEEN @dCurrentDate AND @dNewEndDate)
									)
							 )
          END
          --When both start and end dates have moved
	  -- New start date must always be later date to old start date
	  -- New End Date can be earlier or later to old end date.
        ELSE
          IF ((@dNewStartDate > @dOldStartDate) AND (@dNewEndDate <> @dOldEndDate))
            BEGIN
           
				   /*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
				  Scenario - 5
				  When Start date is moved to later date than old start date AND end date is moved to earlier date or later date than current end date
				  AND DIP Slots have been modified
				  We get  
					 1. Dip affected resos from BETWEEN new Start Date AND new end date
					 2. All resos BETWEEN current date and new start date (exclusing startdate(startdate-1))
					 3.	All resos from new end date forward
					<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
             
                   INSERT INTO @tblDIPAffectedResos
                             (Reservation_ID,
                              Shift_Date,
                              Reservation_Time,
                              RID,
                              Party_size,
                              Date_Made,
                              ReservationStateID,
                              ConfNumber)
                  SELECT   GR.ResID AS Reservation_ID,
                           GR.ShiftDate AS Shift_Date,
                           GR.ResTime AS Reservation_Time,
                           GR.RID,
                           CASE 
								WHEN (COALESCE(GR.seatedSize,0) < 1) THEN GR.Partysize
								ELSE GR.seatedSize
						   END AS Party_size,
                           GR.DateMade AS Date_Made,
                           GR.RStateID AS ReservationStateID,
                           GR.ConfNumber
                  FROM     Reservation GR
                           LEFT OUTER JOIN @tblDIPSlots tb
                             ON GR.ResTIme = tb.TimeSlot
                                AND DATEPART(dw,GR.ShiftDate) = tb.DayOfWeek
                  WHERE    GR.RID = @RID
                           AND RStateID = 1
                           AND GR.ResPoints = 1000
						    AND ( 
								  ((GR.ShiftDate BETWEEN @dCurrentDate AND @dNewStartDate-1)
								   OR (GR.ShiftDate > @dNewEndDate)
								  )
								  OR(tb.TimeSlot IS NOT NULL 
								    AND (GR.ShiftDate BETWEEN @dNewStartDate AND @dNewEndDate)
								  )

								)
            
            END
    END

    --If Start and End Dates are not modified
  ELSE
    BEGIN
			/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
					Scenario 7: When Start date and end date are not modified and DIP Slots Change.
					We get 
						1. Dip affected resos from current date moving forward.
			<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
      INSERT INTO @tblDIPAffectedResos
                 (Reservation_ID,
                  Shift_Date,
                  Reservation_Time,
                  RID,
                  Party_size,
                  Date_Made,
                  ReservationStateID,
                  ConfNumber)
      SELECT   GR.ResID AS Reservation_ID,
               GR.ShiftDate AS Shift_Date,
               GR.ResTime AS Reservation_Time,
               GR.RID,
               CASE 
					WHEN (COALESCE(GR.seatedSize,0) < 1) THEN GR.Partysize
					ELSE GR.seatedSize
               END AS Party_size,
               GR.DateMade AS Date_Made,
               GR.RStateID AS ReservationStateID,
               GR.ConfNumber
      FROM     Reservation GR
               LEFT OUTER JOIN @tblDIPSlots tb
                 ON GR.ResTIme = tb.TimeSlot
                    AND DATEPART(dw,GR.ShiftDate) = tb.DayOfWeek
      WHERE    GR.RID = @RID
               AND GR.ResPoints = 1000
               AND GR.RStateID = 1
               AND (tb.TimeSlot IS NOT NULL AND GR.ShiftDate >= @dCurrentDate)
      
    END

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 Pull additonal information such as RestRef and Reservation State	
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

  SELECT tb.Reservation_ID,
         tb.Shift_Date,
         tb.Reservation_Time,
         tb.RID,
         tb.Party_size,
         tb.Date_Made,
         tb.ReservationStateID,
         tb.ConfNumber,
         dbo.ReservationState.RStateName AS resoState,
         CASE 
           WHEN dbo.ReferrerRestaurantReservationVW.RID IS NULL  THEN 'No'
           ELSE 'Yes'
         END AS restref
  FROM   @tblDIPAffectedResos tb
         INNER JOIN dbo.ReservationState
           ON tb.ReservationStateID = dbo.ReservationState.RStateID
         LEFT OUTER JOIN dbo.ReferrerReservationVW
           ON dbo.ReferrerReservationVW.ResID = tb.Reservation_ID
         LEFT OUTER JOIN dbo.ReferrerRestaurantReservationVW
           ON tb.RID = dbo.ReferrerRestaurantReservationVW.RID
              AND tb.Reservation_ID = dbo.ReferrerRestaurantReservationVW.ResID


GO

GRANT EXECUTE ON [Incentive_GetDIPAffectedResos] TO ExecuteOnlyRole

GO

