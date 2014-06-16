if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_ViewByRestID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_ViewByRestID]
GO

CREATE  PROCEDURE dbo.Extranet_Incentive_ViewByRestID
(
@RestID int,
@Valid bit
)
 AS
 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 
 if @Valid = 1
 
 
BEGIN


     select Incentive.incentiveid as incentive_id,Incentive.IncentiveName as incentive_name,
     DaySchedule.DSchName as day,DaySchedule.DSchID as schedule_ID,ExtranetCostPerCover.Cost as CostPerCover,
     Incentive.amount,Incentive.Startdate as start_date,
     Incentive.createdate as create_date,
     Incentive.Enddate as end_date,Incentive.StartTime as start_time,
     Incentive.EndTime as end_time,
     datedisabled as date_disabled,convert(int,Incentive.active) as Incentive_Status
     from Incentive
     inner join DaySchedule on Incentive.IncentiveDay = DaySchedule.DSchID
     inner join ExtranetCostPerCover on ExtranetCostPerCover.Points = Incentive.Amount
     --left join Reservation on Reservation.incentiveid = Incentive.incentiveid
     where Incentive.RID= @RestID and Incentive.Active= 1 and (Enddate + EndTime) > getdate()
	  and Incentive.LastMinutePopThresholdTime IS NULL
     GROUP BY  Incentive.incentiveid,Incentive.IncentiveName,
     DaySchedule.DSchName,DaySchedule.DSchID,ExtranetCostPerCover.Cost,
     Incentive.amount,Incentive.Startdate,
     Incentive.createdate,
     Incentive.Enddate,Incentive.StartTime,
     Incentive.EndTime,Incentive.datedisabled,Incentive.active
    order by Incentive.Startdate,Incentive.StartTime,Incentive.incentiveid
END
if @Valid = 0

BEGIN
     select Incentive.incentiveid as incentive_id,Incentive.IncentiveName as incentive_name,
     DaySchedule.DSchName as day,DaySchedule.DSchID as schedule_ID,ExtranetCostPerCover.Cost as CostPerCover,
     Incentive.amount,Incentive.Startdate as start_date,
     Incentive.createdate as create_date,
     Incentive.Enddate as end_date,Incentive.StartTime as start_time,
     Incentive.EndTime as end_time,
    Sum(Case
    When (Reservation.RStateID In(2,5,6,7)) Then 1 Else 0 End) As total_resos,
    sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) As total_covers,
   Sum(Case
    When (Reservation.RStateID In(1)) Then 1 Else 0 End) As pending_resos,
    sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) As pending_covers,

     datedisabled as date_disabled,convert(int,Incentive.active) as Incentive_Status
     from Incentive
     inner join DaySchedule on
     Incentive.IncentiveDay = DaySchedule.DSchID
     inner join ExtranetCostPerCover on
     ExtranetCostPerCover.Points = Incentive.Amount
     left join Reservation on Reservation.incentiveid = Incentive.incentiveid
     where Incentive.RID= @RestID and ((Incentive.Active = 0) or ((Enddate + EndTime) < getdate()))
	  and Incentive.LastMinutePopThresholdTime IS NULL
     GROUP BY  Incentive.incentiveid,Incentive.IncentiveName,
     DaySchedule.DSchName,DaySchedule.DSchID,ExtranetCostPerCover.Cost,
     Incentive.amount,Incentive.Startdate,
     Incentive.createdate,
     Incentive.Enddate,Incentive.StartTime,
     Incentive.EndTime,Incentive.datedisabled,convert(int,Incentive.active)
    order by Incentive.incentiveid
End
GO

GRANT EXECUTE ON [Extranet_Incentive_ViewByRestID] TO ExecuteOnlyRole

GO
