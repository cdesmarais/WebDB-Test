if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateMenuURL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateMenuURL]
GO

CREATE Procedure [dbo].[Admin_Restaurant_UpdateMenuURL]
(
    @RestaurantID int,
    @MenuURL nvarchar(255)
)

As

SET NOCOUNT ON

BEGIN TRANSACTION

UPDATE Restaurant
SET
 MenuURL = @MenuURL
WHERE (RID = @RestaurantID)

if @@error <> 0
	goto error

COMMIT TRANSACTION
Return(0)

error:
	ROLLBACK TRANSACTION
	Return(0)


GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateMenuURL] TO ExecuteOnlyRole

GO
