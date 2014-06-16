if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_AvgDRIncentive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_AvgDRIncentive]
GO





CREATE  PROCEDURE dbo.Extranet_Incentive_AvgDRIncentive
(
@RestID int,
@startdate datetime,
@enddate datetime
)
 AS
 SET NOCOUNT ON

Select  avg(Incentive.Amount) as AverageDR from Incentive
where 
RID = @RestID
and (@startdate between Incentive.Startdate and Incentive.Enddate)
and (@startdate between Incentive.Startdate and isnull(Incentive.datedisabled,'1/1/2010'))
GO

GRANT EXECUTE ON [Extranet_Incentive_AvgDRIncentive] TO ExecuteOnlyRole

GO
