if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNSecurityGetUserIPLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNSecurityGetUserIPLog]
GO

CREATE PROCEDURE dbo.DNSecurityGetUserIPLog
 (
  @ClientIP nvarchar(128),
  @ReservationDateTime datetime,
  @RestaurantID int
 )
As
SET NOCOUNT ON

SELECT * 
FROM SecurityLog 
WHERE (ClientIP = @ClientIP 
and RID = @RestaurantID 
and ResDateTime >= @ReservationDateTime)
Return(0)

GO

GRANT EXECUTE ON [DNSecurityGetUserIPLog] TO ExecuteOnlyRole

GO
