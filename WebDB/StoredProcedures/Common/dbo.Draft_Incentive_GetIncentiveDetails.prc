

--This procedure gives the incentive details form the drafted data for a given restaurant.

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Draft_Incentive_GetIncentiveDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Draft_Incentive_GetIncentiveDetails]
go


create Procedure [dbo].[Draft_Incentive_GetIncentiveDetails]
(
    @Rid int
)
as

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 
    select   
        i.Rid as Rid
        ,r.rName as rName
        ,Ma.MetroAreaName as MetroAreaName
        ,Ma.MetroAreaId as MetroAreaId
        ,i.IncentiveId as Incentive_Id
        ,i.IncentiveName as IncentiveName
        ,ds.dschName as IncentiveDay
        ,ds.dsChid as Schedule_Id
        ,ecpc.COST as CostPerCover
        ,i.Amount as Amount
        ,i.StartDate as StartDate
        ,i.CreateDate as CreateDate
        ,i.EndDate as EndDate
        ,i.StartTime as StartTime
        ,i.EndTime as EndTime
        ,1 as IncentiveStatus
        ,i.StartDate + i.StartTime as IncentiveStart
        ,i.EndDate + i.EndTime as IncentiveEnd
        ,n.MacroId as MacroId
        ,null as DateDisabled
        ,i.LastMinutePOPThresholdTime
    from  
        DraftIncentive i

        inner join DaySchedule ds on
        i.IncentiveDay = ds.dsChid

        inner join ExtraNetCostPerCover ecpc on
        ecpc.Points = i.Amount

        inner join RestaurantVW r on
        i.Rid = r.Rid

        inner join NeighborhoodAVW n on
        n.NeighborhoodId = r.NeighborhoodId and
        n.LanguageID = r.LanguageID

        inner join MetroAreaAVW Ma on
        ma.MetroAreaId = n.MetroAreaId and
        ma.LanguageID = r.LanguageID

    where    
        i.Rid = @RID

    order by 
        Ma.MetroAreaName
        ,r.rName
        ,i.StartTime
        ,i.StartDate
        ,i.IncentiveId
go

grant execute on [Draft_Incentive_GetIncentiveDetails] to ExecuteOnlyRole

go

