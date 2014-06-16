if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_LastMinutePOP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_LastMinutePOP]
GO
  
CREATE Procedure dbo.Report_LastMinutePOP  
(  
  @StartDate DATETIME,  
  @EndDate DATETIME  
)  
As  
  
SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  

declare @ShiftDate Datetime

select @ShiftDate = DateAdd(d, -7, @StartDate)

  
SELECT    r.RID, r.RName, m.MetroAreaID, m.MetroAreaName,  
              
             (SELECT      Max(i.CreateDate)   
              FROM        IncentiveVW i  
              INNER JOIN  dbo.ReservationVW reso  
              ON          reso.IncentiveID = i.IncentiveID            
              WHERE       reso.DateMade BETWEEN @StartDate AND @EndDate   
              AND	  reso.ShiftDate > @ShiftDate  -- for performance
              AND         r.RID = reso.RID  
              AND         i.LastMinutePopThresholdTime IS NOT NULL   
              )   AS 'LMPOP Initially Added Date',      
                                        
           (SELECT        COUNT(i.IncentiveID)   
              FROM        IncentiveVW i  
              INNER JOIN  dbo.ReservationVW reso  
              ON          reso.IncentiveID = i.IncentiveID  
              WHERE       reso.DateMade BETWEEN @StartDate AND @EndDate    
              AND	  reso.ShiftDate > @ShiftDate  -- for performance
              AND         r.RID = reso.RID  
              AND         i.LastMinutePopThresholdTime IS NOT NULL  
              ) AS 'LMPOP Resos Booked' ,  
               
             (SELECT    COUNT(reso.IncentiveID)   
              FROM      ReservationVW reso                
              WHERE     DateMade BETWEEN @StartDate AND @EndDate  
              AND	  reso.ShiftDate > @ShiftDate  -- for performance
              AND       r.RID = reso.RID  
              AND       reso.IncentiveID IS NOT NULL              
             ) AS 'Total POP Resos Booked',             
              
             (SELECT    COUNT(resID)  
              FROM      ReservationVW  reso  
              WHERE     DateMade BETWEEN @StartDate AND @EndDate    
              AND	  reso.ShiftDate > @ShiftDate  -- for performance
              AND       BillingType = 'OTReso'      
              AND       r.RID = reso.RID  
              ) AS 'Total OT.com Standard Resos Booked'  
                        
FROM             RestaurantVW r  
INNER JOIN       Neighborhood n   
ON               r.neighborhoodid = n.neighborhoodid  
INNER JOIN       MetroAreaVW m   
ON               n.metroareaid = m.metroareaid  
INNER JOIN       IncentiveVW i  
ON               r.RID = i.RID   
WHERE            LastMinutePopThresholdTime IS NOT NULL   
AND 			 (ISNULL(DateDisabled, EndDate) >= @StartDate)
AND       	     (StartDate <= @EndDate )                
  
GROUP BY          m.MetroAreaName, r.RID, r.RName, m.MetroAreaID    
GO
  
GRANT EXECUTE ON [Report_LastMinutePOP] TO ExecuteOnlyRole  

GRANT EXECUTE ON [Report_LastMinutePOP] TO DTR_User
GO

