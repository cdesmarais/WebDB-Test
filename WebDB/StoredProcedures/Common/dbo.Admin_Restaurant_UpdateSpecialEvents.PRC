if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateSpecialEvents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateSpecialEvents]
GO

CREATE Procedure dbo.Admin_Restaurant_UpdateSpecialEvents
(
    @RestaurantID int,
    @SpecialEvents nvarchar(999) 
)

As

SET NOCOUNT ON


BEGIN TRANSACTION

exec DNRestaurantSetCustomMessageFromName @RestaurantID,'SpecialEvents',@SpecialEvents

if @@error <> 0
	goto error

COMMIT TRANSACTION
Return(0)

error:
	ROLLBACK TRANSACTION
	Return(0)
GO


GRANT EXECUTE ON [Admin_Restaurant_UpdateSpecialEvents] TO ExecuteOnlyRole

GO
