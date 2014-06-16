if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CCDays_Tracking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CCDays_Tracking]
GO



-- Tracks customed Day changes
CREATE PROCEDURE dbo.Admin_CCDays_Tracking
@RestaurantID int, 		-- restaurantID of restaurant who's date is being customed
@customAction nvarchar (255),	-- custom Action
@CCDayID int = 0,		-- CC Day ID to retrieve some info about the day we are tracking (optional)
@Days nvarchar(255),		-- days being customed
@StartTime datetime = null,	-- start shift time (optional)
@EndTime datetime = null,	-- end shift time (optional)
@UserID nvarchar(100)		-- who customed it
AS

SET NOCOUNT ON

if @CCDayID <> 0
begin
	select @StartTime = StartTime, @Endtime = EndTime from CreditCardDay where CCDayID = @CCDayID
end

Insert into CCDayTrack (RID, customAction, Days, StartTime, EndTime, DateChanged, UserID) 
VALUES (@RestaurantID,@customAction,@Days,@StartTime,@EndTime,current_timestamp,@UserID)



GO


GRANT EXECUTE ON [Admin_CCDays_Tracking] TO ExecuteOnlyRole

GO
