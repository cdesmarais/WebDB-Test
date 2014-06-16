if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateMessages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateMessages]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_UpdateMessages
(@RID int
,@NoAvailability nvarchar(999)
,@MaxParty nvarchar(999)
,@MinParty nvarchar(999)
,@LargeParty nvarchar(999)
,@Cutoff nvarchar(999)
,@SameCutoff nvarchar(999)
,@CCDay nvarchar(999)
,@Confirmation nvarchar(999)
,@Details nvarchar(999)
)
AS

EXEC DNRestaurantSetCustomMessage @RID, 9, @NoAvailability
EXEC DNRestaurantSetCustomMessage @RID, 4, @MaxParty
EXEC DNRestaurantSetCustomMessage @RID, 3, @MinParty
EXEC DNRestaurantSetCustomMessage @RID, 12, @LargeParty
EXEC DNRestaurantSetCustomMessage @RID, 6, @Cutoff
EXEC DNRestaurantSetCustomMessage @RID, 5, @SameCutoff
EXEC DNRestaurantSetCustomMessage @RID, 11, @CCDay
EXEC DNRestaurantSetCustomMessage @RID, 10, @Confirmation
EXEC DNRestaurantSetCustomMessage @RID, 15, @Details
GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateMessages] TO ExecuteOnlyRole

GO
