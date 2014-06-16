if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_ViewCurrent_ByRest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_ViewCurrent_ByRest]
GO





CREATE Procedure dbo.Extranet_Incentive_ViewCurrent_ByRest
(
	@RestID int
)

AS
SET NOCOUNT ON

select Incentive.incentiveid as incentive_id,Incentive.IncentiveName as incentive_name,
     DaySchedule.DSchName as day,DaySchedule.DSchID as schedule_ID,ExtranetCostPerCover.Cost as CostPerCover,
     Incentive.amount,Incentive.Startdate as start_date,
     Incentive.createdate as create_date,
     Incentive.Enddate as end_date,Incentive.StartTime as start_time,
     Incentive.EndTime as end_time,convert(int,Incentive.active) as Incentive_Status
     from Incentive
     inner join DaySchedule on Incentive.IncentiveDay = DaySchedule.DSchID
     inner join ExtranetCostPerCover on ExtranetCostPerCover.Points = Incentive.Amount
     where Incentive.RID= @RestID and Incentive.Active= 1 and (Enddate + EndTime) > getdate()
	  and Incentive.LastMinutePopThresholdTime IS NULL
     GROUP BY  Incentive.incentiveid,Incentive.IncentiveName,
     DaySchedule.DSchName,DaySchedule.DSchID,ExtranetCostPerCover.Cost,
     Incentive.amount,Incentive.Startdate,
     Incentive.createdate,
     Incentive.Enddate,Incentive.StartTime,
     Incentive.EndTime,Incentive.datedisabled,convert(int,Incentive.active)
    order by DaySchedule.DSchID,Incentive.Startdate,Incentive.StartTime,Incentive.incentiveid
GO

GRANT EXECUTE ON [Extranet_Incentive_ViewCurrent_ByRest] TO ExecuteOnlyRole

GO
