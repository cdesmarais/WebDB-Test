if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_Cancel_Logv1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_Cancel_Logv1]
GO


CREATE Procedure dbo.Admin_Restaurant_Cancel_Logv1

(@RID int,
 @NotesToDiner NVARCHAR(999),
 @RestaurantStateID int
)

AS
SET NOCOUNT ON

declare @CancellationRestLogID int = -1

Insert into CancelRestaurantLog (RID, NotesToDiner, RestaurantStateID) 
values (@RID, @NotesToDiner, @RestaurantStateID)

if @@error = 0
	set @CancellationRestLogID = @@identity

select @CancellationRestLogID

GO

GRANT EXECUTE ON [Admin_Restaurant_Cancel_Logv1] TO ExecuteOnlyRole

GO