if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddUpdateDeleteBlockedDayDefault]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddUpdateDeleteBlockedDayDefault]
GO

-- Procedure adds/updates/deletes blocked dates
CREATE PROCEDURE dbo.Admin_AddUpdateDeleteBlockedDayDefault
@RestaurantID int, 		-- restaurantID of restaurant who's date is being blocked
@BlockedDate datetime, 		-- date being blocked
@BlockedBy nvarchar(50)		-- who blocked it
AS

SET NOCOUNT ON

BEGIN TRANSACTION

-- determine if we need to update or insert..
declare @IsUpdate int, @Dayid int
set @IsUpdate=0

-- delete and then insert..
DELETE FROM [BlockedDaylocal] WHERE DayID IN (
SELECT DayID FROM [BlockedDay] WHERE RID = @RestaurantID AND BlockedDate = @BlockedDate
)

DELETE FROM [BlockedDay] WHERE RID = @RestaurantID AND BlockedDate = @BlockedDate

-- insert customed day..
Insert into BlockedDay (RID, BlockedDate,BlockedBy,BlockReason) 
VALUES (@RestaurantID,@BlockedDate,@BlockedBy,'4')

Set @Dayid = @@Identity

-- insert customed day local..
-- MMC 10/29/08 MMC: TT 27154 use NULL rather than '' for the Message so the default is cached
Insert into BlockedDaylocal (DayID, Message, LanguageID)
SELECT 	@Dayid as DayID, 
	NULL,  
	DefaultMessage.LanguageID 
FROM 		DefaultMessage 
INNER JOIN 	[RestaurantLocal] 
ON 		[DefaultMessage].[LanguageID] = [RestaurantLocal].[LanguageID]
WHERE [MessageTypeID] = 1 AND rid = @RestaurantID


COMMIT TRANSACTION

GO

GRANT EXECUTE ON [Admin_AddUpdateDeleteBlockedDayDefault] TO ExecuteOnlyRole

GO
