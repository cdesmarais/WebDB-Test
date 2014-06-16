if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_customDays_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_customDays_Delete]
GO




CREATE PROCEDURE dbo.Admin_customDays_Delete 

@restaurant_id int,
@UncustomAll int,
@Assignment_Date datetime

AS

if @UncustomAll = 1 
	BEGIN
		delete from customedDayLocal where dayID in (select DayID from customedDay where RID = @restaurant_id)
		delete from customedDay where RID = @restaurant_id

	END
else
	BEGIN
		delete from customedDayLocal where dayID in (select DayID from customedDay where RID = @restaurant_id and customedDate =@Assignment_Date)
		delete from customedDay where RID = @restaurant_id and customedDate =@Assignment_Date	
	END





GO


GRANT EXECUTE ON [Admin_customDays_Delete] TO ExecuteOnlyRole

GO
