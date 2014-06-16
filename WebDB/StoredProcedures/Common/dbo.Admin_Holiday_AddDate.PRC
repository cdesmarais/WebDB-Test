if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Holiday_AddDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Holiday_AddDate]
GO


CREATE PROCEDURE dbo.Admin_Holiday_AddDate
 (
  @Holiday_ID int,
  @Holiday_Date datetime,
  @CountryID nvarchar(4),
  @SuppressDIP bit
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

-- akash: Disallow duplicate holidays! As of now our schema does not support different holidays on the SAME day
-- for now we will prevent the addition of duplicate holidays, will be fixed in coming versions..
Declare @Holiday_Count int
select @Holiday_Count=count(*) from holidayschedule where @Holiday_Date=HolidayDate and (CountryID = @CountryID OR CountryID = 'ALL');
if (@Holiday_Count > 0)
	goto duplicate_error

INSERT INTO HolidaySchedule
 (
  HolidayID,
  HolidayDate,
  CountryID,
  SuppressDIP
 )
VALUES
 (
  @Holiday_ID,
  @Holiday_Date,
  @CountryID,
  @SuppressDIP
 )

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

duplicate_error:
	ROLLBACK TRANSACTION
	RAISERROR('Admin_Holiday_AddDate FAILED: Cannot add duplicate holiday!',16,1)
	Return(0)


GO


GRANT EXECUTE ON [Admin_Holiday_AddDate] TO ExecuteOnlyRole

GO
