if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateNoShowDispute]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateNoShowDispute]
GO

CREATE PROCEDURE dbo.DNUpdateNoShowDispute
(
	@nReservationID int,
	@nResolved bit
)
 AS

SET NOCOUNT ON

UPDATE LogNoShowDisputes 
SET Resolved = @nResolved
WHERE LogNoShowDisputes.ResID = @nReservationID
GO


GRANT EXECUTE ON [DNUpdateNoShowDispute] TO ExecuteOnlyRole

GO
