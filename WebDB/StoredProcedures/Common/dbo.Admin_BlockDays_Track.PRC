if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_BlockDays_Track]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_BlockDays_Track]
GO

-- Tracks Blocked Day changes
CREATE PROCEDURE dbo.Admin_BlockDays_Track
@RestaurantID int, 		-- restaurantID of restaurant who's date is being blocked
@BlockAction nvarchar (255),	-- block Action
@Days nvarchar(255),		-- days being blocked
@UserID nvarchar(100),		-- who blocked it
@BlockReason int		-- Blocked Day Reason
AS

SET NOCOUNT ON

Insert into BlockedDayTrack (RID, BlockAction, Days,DateChanged,UserID,BlockReason) 
VALUES (@RestaurantID,@BlockAction,@Days,current_timestamp,@UserID,@BlockReason)
GO


GRANT EXECUTE ON [Admin_BlockDays_Track] TO ExecuteOnlyRole

GO
