if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNSecurityRemoveIPLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNSecurityRemoveIPLog]
GO

CREATE PROCEDURE dbo.DNSecurityRemoveIPLog
@ReservationID int

AS

begin

DELETE from SecurityLog WHERE ResID = @ReservationID
end
GO

GRANT EXECUTE ON [DNSecurityRemoveIPLog] TO ExecuteOnlyRole

GO
