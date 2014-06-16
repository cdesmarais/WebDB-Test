if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_Reservation_GetRestaurantID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_Reservation_GetRestaurantID]
GO

CREATE PROCEDURE dbo.XML_Reservation_GetRestaurantID
(
@ReservationID int
,@retVal int OUTPUT
)

As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select @retVal = RID from Reservation where ResID = @ReservationID
if @retVal is null
	set @retVal = 0
	
GO

GRANT EXECUTE ON [XML_Reservation_GetRestaurantID] TO ExecuteOnlyRole

GO
