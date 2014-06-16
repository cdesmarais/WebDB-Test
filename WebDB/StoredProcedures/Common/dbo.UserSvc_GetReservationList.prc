if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_GetReservationList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserSvc_GetReservationList]
GO


CREATE PROCEDURE dbo.UserSvc_GetReservationList
	(
		@GlobalPersonId bigint
	)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	proc_UserSvc_GetCallerReservationList
--**	proc_UserSvc_GetCustomerReservationList
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
	exec proc_UserSvc_GetCallerReservationList @CallerID
END
else
BEGIN
	exec proc_UserSvc_GetCustomerReservationList @CustID
END
GO

GRANT EXECUTE ON [UserSvc_GetReservationList] TO ExecuteOnlyRole

GO
