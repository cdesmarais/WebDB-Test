if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_ViewByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_ViewByID]
GO






CREATE Procedure dbo.Extranet_Incentive_ViewByID
@IncentiveID int

As
SET NOCOUNT ON
-- Return all Valid Incentives
     select Incentive.IncentiveName as incentive_name,
     DaySchedule.DSchName as DayofWeek,ExtranetCostPerCover.Cost,
     Incentive.Amount,Incentive.Startdate as Start_date,
     Incentive.Enddate as End_date,Incentive.createdate as create_date,
     Incentive.StartTime as Start_Time,Incentive.EndTime as End_Time,
     Incentive.active,Incentive.IncentiveDay as day,
     Incentive.datedisabled as Date_Disabled
     from 
     Incentive inner join
     DaySchedule on 
     Incentive.IncentiveDay = DaySchedule.DSchID 
     inner join ExtranetCostPerCover on 
     ExtranetCostPerCover.Points = Incentive.Amount
     where
     incentiveid = @IncentiveID
	  and Incentive.LastMinutePopThresholdTime IS NULL
GO

GRANT EXECUTE ON [Extranet_Incentive_ViewByID] TO ExecuteOnlyRole

GO
