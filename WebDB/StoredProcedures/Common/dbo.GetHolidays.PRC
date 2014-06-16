if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetHolidays]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetHolidays]
GO


--************************
--** OBSOLETE; Not called by 4.0 webiste
--************************
CREATE PROCEDURE dbo.GetHolidays
(
	@holidate datetime
)

AS
SET NOCOUNT ON

Select		h.HolidayName as Name 
from		HolidaySchedule hs
inner join	HolidaysVW h 
on			h.HolidayID = hs.HolidayID
where		hs.HolidayDate = @holidate
GO

GRANT EXECUTE ON [GetHolidays] TO ExecuteOnlyRole

GO
