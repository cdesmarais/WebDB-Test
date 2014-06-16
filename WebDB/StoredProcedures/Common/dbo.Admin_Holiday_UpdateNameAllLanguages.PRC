if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Holiday_UpdateNameAllLanguages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Holiday_UpdateNameAllLanguages]
GO

CREATE Procedure dbo.Admin_Holiday_UpdateNameAllLanguages
 (
  @HolidayNames nvarchar(4000),
  @LanguageIDs nvarchar(255),
  @Holiday_ID int
 )
As
SET NOCOUNT ON

BEGIN TRANSACTION
declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @id int

--**********************
--** Update Local
--**********************
set @Action = 'Update HolidaysLocal'

UPDATE HolidaysLocal 
SET 	HolidaysLocal.HolidayName = h.[Value]
FROM	dbo.fMergeListsToTab(@LanguageIDs, @HolidayNames, '#', '#') h
WHERE	HolidaysLocal.HolidayID =  @Holiday_ID
AND	HolidaysLocal.LanguageID = h.[Key]

set @DBError = @@error
if @DBError <> 0
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)
GO


GO

GRANT EXECUTE ON dbo.[Admin_Holiday_UpdateNameAllLanguages] TO ExecuteOnlyRole

GO