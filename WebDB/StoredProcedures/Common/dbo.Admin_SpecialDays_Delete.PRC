if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_SpecialDays_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_SpecialDays_Delete]
GO




CREATE PROCEDURE dbo.Admin_SpecialDays_Delete 

@restaurant_id int,
@Schedule_ID int

AS
BEGIN TRANSACTION

delete from ScheduleShifts where scheduleID = @Schedule_ID and RID = @restaurant_id
if (@@ERROR <> 0)
	goto general_error

delete from SpcSchAssign where scheduleID = @Schedule_ID
if (@@ERROR <> 0)
	goto general_error

delete from DaySchedule where DSchID = @Schedule_ID
if (@@ERROR <> 0)
	goto general_error


COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_SpecialDays_Delete] TO ExecuteOnlyRole

GO
