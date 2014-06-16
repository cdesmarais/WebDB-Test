if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNSecurityLogUserIP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNSecurityLogUserIP]
GO

CREATE PROCEDURE dbo.DNSecurityLogUserIP
 (
  @ReservationID int,
  @UserID int,
  @ReservationDateTime datetime,
  @RestaurantID int,
  @ClientIP nvarchar(128)
 )
As
SET NOCOUNT ON

BEGIN TRANSACTION

-- Clean up and remove any record of IPs that have reservation dates that has passed
DELETE FROM SecurityLog  
WHERE ((ResDateTime + 1) < getdate())

-- Insert new log record
INSERT INTO SecurityLog (ResID,UserID,ResDateTime,RID,ClientIP) 
VALUES (@ReservationID,@UserID,@ReservationDateTime,@RestaurantID,@ClientIP)
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [DNSecurityLogUserIP] TO ExecuteOnlyRole

GO
