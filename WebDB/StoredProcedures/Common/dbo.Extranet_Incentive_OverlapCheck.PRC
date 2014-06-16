if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_OverlapCheck]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_OverlapCheck]
GO






CREATE Procedure dbo.Extranet_Incentive_OverlapCheck 

@DayOfWeek int,
@RestID int,
@StartDate datetime,
@EndDate datetime,
@StartTime datetime,
@EndTime datetime,
@IncentiveID int = 0,
@retval int OUTPUT

AS
SET NOCOUNT ON
if exists
(
   Select * from Incentive

   where

   RID = @RestID  and 
   IncentiveDay = @DayOfWeek  and
   active = 1 and  
   incentiveid <> @IncentiveID and 
   Enddate > getDate()  --we do not want ones that have already passed.

   and 
     
   ((Startdate <=  @StartDate  and @StartDate <= Enddate) or 
   (Startdate <= @EndDate  and @EndDate <= Enddate) or 
   (Startdate >= @StartDate  and @EndDate  >= Startdate))

   and 

   ((StartTime <=  @StartTime  and @StartTime < EndTime) or 
   (StartTime <  @EndTime  and @EndTime <= EndTime) or 
   (StartTime >= @StartTime  and @EndTime  > StartTime))
)

Select @retval = 1

else 

Select @retval = 0
GO

GRANT EXECUTE ON [Extranet_Incentive_OverlapCheck] TO ExecuteOnlyRole

GO
