if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_customDays_Track]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_customDays_Track]
GO



-- Tracks customed Day changes
CREATE PROCEDURE dbo.Admin_customDays_Track
@RestaurantID int, 		-- restaurantID of restaurant who's date is being customed
@customAction nvarchar (255),	-- custom Action
@Days nvarchar(255),		-- days being customed
@UserID nvarchar(100)		-- who customed it
AS

SET NOCOUNT ON

Insert into customedDayTrack (RID, customAction, Days,DateChanged,UserID) 
VALUES (@RestaurantID,@customAction,@Days,current_timestamp,@UserID)



GO


GRANT EXECUTE ON [Admin_customDays_Track] TO ExecuteOnlyRole

GO
