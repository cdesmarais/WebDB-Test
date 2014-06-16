if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_Insert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_Insert]
GO






CREATE Procedure dbo.Extranet_Incentive_Insert

(@RestaurantID int,
@IncentiveName nvarchar(4000),
@Day int,
@Amount int,
@StartDate datetime,
@EndDate datetime,
@StartTime datetime,
@EndTime datetime)

AS
SET NOCOUNT ON
Insert into Incentive (RID,IncentiveName,IncentiveDay,Amount,Startdate,Enddate,StartTime,EndTime) 
values (@RestaurantID,@IncentiveName,@Day,@Amount,@StartDate,@EndDate,@StartTime,@EndTime)
GO

GRANT EXECUTE ON [Extranet_Incentive_Insert] TO ExecuteOnlyRole

GO
