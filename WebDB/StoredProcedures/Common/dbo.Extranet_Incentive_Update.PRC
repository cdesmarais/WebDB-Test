if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Incentive_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Incentive_Update]
GO







CREATE Procedure dbo.Extranet_Incentive_Update

@RestaurantID int,
@IncentiveName nvarchar(999),
@Day int,
@Amount int,
@StartDate datetime,
@EndDate datetime,
@StartTime datetime,
@EndTime datetime,
@IncentiveID int

as
SET NOCOUNT ON

/* make new Incentive */
Exec Extranet_Incentive_Insert @RestaurantID = @RestaurantID,@IncentiveName = IncentiveName,@Day=@Day,@Amount=@Amount,
                                                  @StartDate=@StartDate,@EndDate=@EndDate,@StartTime=@StartTime,@EndTime=@EndTime


/* disable old Incentive */
update Incentive set active = 0 where incentiveid = @IncentiveID
GO

GRANT EXECUTE ON [Extranet_Incentive_Update] TO ExecuteOnlyRole

GO
