if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetRestaurantIdByMigratedReservationId]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetRestaurantIdByMigratedReservationId]
GO

CREATE PROCEDURE [dbo].[DNGetRestaurantIdByMigratedReservationId]
 (
	@ReservationId INT,
	@RestaurantId INT OUTPUT
 )
As

SET NOCOUNT ON

SELECT @RestaurantId = r.RID FROM [dbo].[UK_Migrated_Reservation] r WHERE r.ResID = @ReservationId

GO

GRANT EXECUTE ON [DNGetRestaurantIdByMigratedReservationId] TO ExecuteOnlyRole
GO