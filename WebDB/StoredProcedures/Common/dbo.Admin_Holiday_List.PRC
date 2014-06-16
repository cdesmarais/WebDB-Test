if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Holiday_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Holiday_List]
GO


CREATE PROCEDURE dbo.Admin_Holiday_List
(
  @Holiday_ID int = 0
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
if @Holiday_ID = 0
  BEGIN
  

	Select	Distinct	override
				,h.HolidayName as Name
				,h.HolidayID as Holiday_ID
				,CountryID 
 				,SuppressDIP
	from		HolidaySchedule
	inner join	HolidaysVW h
	on			h.HolidayID = HolidaySchedule.HolidayID
	where		HolidayDate > current_timestamp-1
	order by	name
  END
if @Holiday_ID <> 0
  BEGIN
 	Select		override
 				,h.HolidayName as Name
 				,HolidayDate as Holiday_Date
 				,DateID as Date_ID
 				,CountryID 
 				,SuppressDIP
 	from		HolidaySchedule
	inner join	HolidaysVW h
	on			h.HolidayID = HolidaySchedule.HolidayID
	where		h.HolidayID = @Holiday_ID 
	and			HolidayDate > current_timestamp-1

  END
GO

GRANT EXECUTE ON [Admin_Holiday_List] TO ExecuteOnlyRole

GO
