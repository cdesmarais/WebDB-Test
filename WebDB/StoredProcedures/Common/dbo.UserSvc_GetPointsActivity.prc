if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_GetPointsActivity]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserSvc_GetPointsActivity]
GO

CREATE PROCEDURE dbo.UserSvc_GetPointsActivity
	(
		@GlobalPersonId bigint,
		@LanguageID int,
		@StartDT datetime = '1900-01-01',
		@EndDT datetime = '9999-12-31'
	)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	proc_UserSvc_GetCallerInfo
--**	proc_UserSvc_GetCustomerInfo
--**
--** These procs are part of a pair. 
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************

declare @CustID int, @CallerID int
 
select @CustID = CustID
	,@CallerID = CallerID
from GlobalPerson
where _GlobalPersonID = @GlobalPersonId

if @CallerID is not null
BEGIN
	exec proc_UserSvc_GetPointsActivity_Caller @CallerID, @LanguageID, @StartDT, @EndDT
END
else
BEGIN
	exec proc_UserSvc_GetPointsActivity_Cust @CustID, @LanguageID, @StartDT, @EndDT
END

GO

GRANT EXECUTE ON [UserSvc_GetPointsActivity] TO ExecuteOnlyRole

GO
