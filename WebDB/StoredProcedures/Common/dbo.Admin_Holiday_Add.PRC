if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Holiday_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Holiday_Add]
GO

CREATE PROCEDURE dbo.Admin_Holiday_Add
 (
  @Holiday_Name nvarchar(255),
  @Holiday_Date datetime,
  @CountryID nvarchar(4),
  @SuppressDIP bit
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @ID int

set @ProcName = 'Admin_Holiday_Add'

--**********************
--** Get Language
--**********************
set @Action = 'Retrieve LanguageID'
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID
set @DBError = @@error
if @DBError <> 0
	goto general_error

-- akash: Disallow duplicate holidays! As of now our schema does not support different holidays on the SAME day
-- for now we will prevent the addition of duplicate holidays, will be fixed in coming versions..
Declare @Holiday_Count int
select @Holiday_Count=count(*) from holidayschedule where @Holiday_Date=HolidayDate and CountryID = @CountryID;
if (@Holiday_Count > 0)
	goto duplicate_error

--*******************
--** Create Master Record
--*******************
set @Action = 'INSERT INTO Holidays'
INSERT INTO Holidays
 (
  Override
 )
VALUES
 (
  0
 )

set @DBError = @@error
if @DBError <> 0
	goto general_error
	
set @ID = scope_identity()

--*******************
--** Create Local Record
--*******************
set @Action = 'INSERT INTO HolidaysLocal'

-- IF this is for All countries, add the holiday to all languages.
if @CountryID = 'ALL'
BEGIN
	INSERT INTO HolidaysLocal
	 (
	  HolidayID,
	  LanguageID,
	  HolidayName
	 )
	 Select @ID as HolidayID,
	 	LanguageID,
	 	@Holiday_Name as HolidayName
	 from 	[Language] 
	 WHERE 	active = 1
END
else
BEGIN
	INSERT INTO HolidaysLocal
	 (
	  HolidayID,
	  LanguageID,
	  HolidayName
	 )
	 Select @ID as HolidayID,
	 	LanguageID,
	 	@Holiday_Name as HolidayName
	 FROM 	[MetroArea]
	 INNER JOIN [MetroAreaLocal] 
	 ON 	[MetroArea].[MetroAreaID] = [MetroAreaLocal].[MetroAreaID]
	WHERE 	[CountryID] = @CountryID 
	AND 	[MetroArea].MetroAreaID != 1
	AND 	Active = 1
END

set @DBError = @@error
if @DBError <> 0
	goto general_error

--*******************
--** Create HolidaySchedule
--*******************
set @Action = 'INSERT INTO HolidaySchedule'
INSERT INTO HolidaySchedule
 (
  HolidayID,
  HolidayDate,
  CountryID,
  SuppressDIP
 )
VALUES
 (
  @ID,
  @Holiday_Date,
  @CountryID,
  @SuppressDIP
)

set @DBError = @@error
if @DBError <> 0
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)

duplicate_error:
	ROLLBACK TRANSACTION
	RAISERROR('Admin_Holiday_Add FAILED: Cannot add duplicate holiday!',16,1)
	Return(0)


GO


GRANT EXECUTE ON [Admin_Holiday_Add] TO ExecuteOnlyRole

GO
