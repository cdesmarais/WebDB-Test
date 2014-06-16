if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetHolidaysAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetHolidaysAll]
GO


--*******************************
-- Called by CacheManager
--*******************************
CREATE PROCEDURE dbo.GetHolidaysAll

AS
SET NOCOUNT ON
set transaction isolation level read uncommitted

Select		h.HolidayName as Name,
			hs.HolidayDate as Holiday_Date, 
			SuppressDIP,
			coalesce(CountryID,'ALL') as  CountryID
from		HolidaySchedule hs
inner join	HolidaysVW h
on			h.HolidayID = hs.HolidayID

GO


GRANT EXECUTE ON [GetHolidaysAll] TO ExecuteOnlyRole

GO
