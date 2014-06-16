if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_GetIncentiveDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_GetIncentiveDetails]
GO


CREATE Procedure [dbo].[Incentive_GetIncentiveDetails]
(
  @Rid int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
 


SELECT   i.Rid AS Rid,
           r.rName AS [rName],
           Ma.MetroAreaName AS [MetroAreaName],
           Ma.MetroAreaId AS MetroAreaId,
           i.IncentiveId AS [Incentive_Id],
           i.IncentiveName AS IncentiveName,
           ds.dschName AS IncentiveDay,
           ds.dsChid AS Schedule_Id,
           ecpc.COST AS CostPerCover,
           i.Amount AS Amount,
           i.StartDate AS [StartDate],
           i.CreateDate AS CreateDate,
           i.EndDate AS EndDate,
           i.StartTime AS [StartTime],
           i.EndTime AS EndTime,
           DateDisabled AS DateDisabled,
           CONVERT(INT,i.Active) AS IncentiveStatus,
           i.StartDate + i.StartTime AS IncentiveStart,
           i.EndDate + i.EndTime AS IncentiveEnd,
           n.MacroId AS MacroId
  FROM     Incentive i
           INNER JOIN DaySchedule ds
             ON i.IncentiveDay = ds.dsChid
           INNER JOIN ExtraNetCostPerCover ecpc
             ON ecpc.Points = i.Amount
           INNER JOIN RestaurantVW r
             ON i.Rid = r.Rid
           INNER JOIN	NeighborhoodAVW n
             ON			n.NeighborhoodId = r.NeighborhoodId
            and			n.LanguageID = r.LanguageID
           INNER JOIN	MetroAreaAVW Ma
             ON			ma.MetroAreaId = n.MetroAreaId
            and			ma.LanguageID = r.LanguageID
  WHERE    i.Active = 1
           AND i.Rid = @RID
           and I.LastMinutePopThresholdTime IS NULL
  GROUP BY i.Rid,r.rName,Ma.MetroAreaName,i.IncentiveId,
           i.IncentiveName,ds.dschName,ds.dsChid,ecpc.COST,
           i.Amount,i.StartDate,i.CreateDate,i.EndDate,
           i.StartTime,i.EndTime,i.DateDisabled,i.Active,
           Ma.MetroAreaId,n.MacroId
  ORDER BY [MetroAreaName],
           [rName],
           [StartTime],
           [StartDate],
           [Incentive_Id]

Go

GRANT EXECUTE ON [Incentive_GetIncentiveDetails] TO ExecuteOnlyRole

Go
