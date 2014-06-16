if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddUpdateDeletecustomedDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddUpdateDeletecustomedDay]
GO

--*********************************
--** OBSOLETE as of i18n MX
--*********************************

-- Procedure adds/updates/deletes customed dates
CREATE PROCEDURE dbo.Admin_AddUpdateDeletecustomedDay
@RestaurantID int, 		-- restaurantID of restaurant who's date is being customed
@customedDate datetime, 		-- date being customed
@Message nvarchar (500),		-- custom message
@customedBy nvarchar(50),		-- who customed it
@IsDelete int			-- are we deleting the customed day? If set to 1, the customed day will be deleted
AS

SET NOCOUNT ON

BEGIN TRANSACTION

-- determine if we need to update or insert..
declare @IsUpdate int
set @IsUpdate=0

declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID  

declare @DayID int
-- check if a record exists for this rid/customedday combination..if it does delete it first
if exists(select * from customedDay where RID = @RestaurantID and customedDate =@customedDate) OR @IsDelete=1
	BEGIN
		-- delete and then insert..
		delete from customedDayLocal where dayID in (select DayID from customedDay where RID = @RestaurantID and customedDate =@customedDate) and languageID = @LanguageID
		delete from customedDay where RID = @RestaurantID and customedDate =@customedDate
	END

-- insert a new record only if its NOT a delete
if @IsDelete=0
	BEGIN
		-- insert customed day..
		Insert into customedDay (RID, customedDate, customedBy) 
		VALUES (@RestaurantID,@customedDate,@customedBy)
		
		set @DayId = scope_identity()
		
		Insert into customedDayLocal values (@DayID, @Message, @LanguageID)
	END


COMMIT TRANSACTION




GO


GRANT EXECUTE ON [Admin_AddUpdateDeletecustomedDay] TO ExecuteOnlyRole

GO
