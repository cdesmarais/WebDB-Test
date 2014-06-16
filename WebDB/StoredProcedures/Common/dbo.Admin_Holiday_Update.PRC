if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Holiday_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Holiday_Update]
GO


CREATE PROCEDURE dbo.Admin_Holiday_Update
 (
  @Holiday_Date datetime,
  @CountryID nvarchar(4),
  @Date_ID int,
  @SuppressDIP bit
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

-- akash: Disallow duplicate holidays! As of now our schema does not support different holidays on the SAME day
-- for now we will prevent the addition of duplicate holidays, will be fixed in coming versions..
Declare @Holiday_Count int
select @Holiday_Count=count(*) from holidayschedule
where @Date_ID <> DateID
and @Holiday_Date=HolidayDate
and (CountryID = @CountryID OR CountryID = 'ALL');
if (@Holiday_Count > 0)
	goto duplicate_error

UPDATE HolidaySchedule
SET HolidayDate  = @Holiday_Date, CountryID = @CountryID, SuppressDIP = @SuppressDIP
WHERE DateID=  @Date_ID

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

duplicate_error:
	ROLLBACK TRANSACTION
	RAISERROR('Admin_Holiday_Update FAILED: Cannot add duplicate holiday!',16,1)
	Return(0)

GO


GRANT EXECUTE ON [Admin_Holiday_Update] TO ExecuteOnlyRole

GO
