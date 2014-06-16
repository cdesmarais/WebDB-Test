if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogNoShowDispute]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogNoShowDispute]
GO

CREATE PROCEDURE dbo.DNLogNoShowDispute
(
	@nReservationID int,
	@sMessage nvarchar(300),
	@nReason int,
	@nUserID int,
	@nIsCaller bit
)
 AS

SET NOCOUNT ON

INSERT INTO LogNoShowDisputes (ResID,Message,Reason,Resolved,UserID,IsCaller) 
	VALUES (@nReservationID,@sMessage,@nReason,0,@nUserID,@nIsCaller)
GO


GRANT EXECUTE ON [DNLogNoShowDispute] TO ExecuteOnlyRole

GO
