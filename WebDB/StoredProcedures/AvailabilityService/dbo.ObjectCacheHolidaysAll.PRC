if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheHolidaysAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheHolidaysAll]
GO


--*******************************
-- Called by CacheManager
--*******************************
CREATE PROCEDURE dbo.ObjectCacheHolidaysAll

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
return 0
SELECT		hs.HolidayDate as Holiday_Date, 
			SuppressDIP,
			coalesce(CountryID,'ALL') as  CountryID
FROM		HolidaySchedule hs
INNER JOIN	Holidays h
ON			h.HolidayID = hs.HolidayID
WHERE		hs.HolidayDate > GETDATE() - 1

GO


GRANT EXECUTE ON [ObjectCacheHolidaysAll] TO ExecuteOnlyRole

GO
