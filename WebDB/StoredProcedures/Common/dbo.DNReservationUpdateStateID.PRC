if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationUpdateStateID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationUpdateStateID]
GO

CREATE PROCEDURE dbo.DNReservationUpdateStateID
(
	@nReservationID int,
	@nReservationState int
)
 AS
--**************************************************************************************
--** Begin OBOSLETE LOG
--** The following will log the fact that this obsolete proc was exectured into LogDB..ErrorLog
--** This snippet can be cut and pasted in to any block of code that is thought to be obsolete
--**************************************************************************************
	declare @_ErrorMessage nvarchar(1000)
	set @_ErrorMessage = 'PROC called'

	declare @_objName nvarchar(1000)
	SELECT	@_objName = OBJECT_NAME(@@PROCID), 
			@_ErrorMessage = @_ErrorMessage 
							+ ': '+ @_objName
							+ '  by host: ' + rtrim(isnull(hostname, 'unknown'))
							+ '  User: ' + rtrim(isnull(loginame, 'unknown'))
	FROM	sys.sysprocesses 
	WHERE	spid = @@spid  
	exec procLogProcedureError 9, @_objName, 'OBSOLETE', @_ErrorMessage
--**************************************************************************************
--** End OBOSLETE LOG
--**************************************************************************************

SET NOCOUNT ON
if EXISTS(select RStateID from Reservation where ResID = @nReservationID)
begin
	update Reservation set RStateID = @nReservationState
		where ResID = @nReservationID
end
GO


GRANT EXECUTE ON [DNReservationUpdateStateID] TO ExecuteOnlyRole

GO
