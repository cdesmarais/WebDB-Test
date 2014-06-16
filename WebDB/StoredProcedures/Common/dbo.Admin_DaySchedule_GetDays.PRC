if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DaySchedule_GetDays]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DaySchedule_GetDays]
GO




CREATE PROCEDURE dbo.Admin_DaySchedule_GetDays
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DSchID as schedule_ID,DSchName as Name
FROM DaySchedule
GO

GRANT EXECUTE ON [Admin_DaySchedule_GetDays] TO ExecuteOnlyRole

GO
