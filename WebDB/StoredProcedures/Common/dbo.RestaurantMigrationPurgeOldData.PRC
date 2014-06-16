if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantMigrationPurgeOldData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantMigrationPurgeOldData]
GO

CREATE PROCEDURE dbo.[RestaurantMigrationPurgeOldData]
AS
-- purges RestaurantMigratedReso records whose shift date is older than 30 days from today's date

DECLARE @ErrMsg NVARCHAR(150)
DECLARE @TodaysDate DATETIME
DECLARE @DaysToGoBehind INT
BEGIN
	SET @TodaysDate = GETUTCDATE()
	SET @DaysToGoBehind = 30

	delete RestaurantMigratedReso 
	
	from RestaurantMigratedReso m	
	
	inner join  Reservation                     reso	
	on          reso.ResID                      = m.ResID
	
	where       reso.ShiftDate < @TodaysDate - @DaysToGoBehind 
	
	IF @@ERROR <> 0
	begin
	        SET @ErrMsg = 'dbo.RestaurantMigrationPurgeOldData: Error purging old restaurant migration data'
		RAISERROR(@ErrMsg, 16, 1)		
	end
END
GO

GRANT EXECUTE ON [RestaurantMigrationPurgeOldData] TO ConsoleExecuteRole
GO