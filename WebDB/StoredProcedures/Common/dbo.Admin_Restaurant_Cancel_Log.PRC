if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_Cancel_Log]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_Cancel_Log]
GO


CREATE Procedure dbo.Admin_Restaurant_Cancel_Log

(@RID int,
 @NotesToDiner NVARCHAR(999)
)

AS
SET NOCOUNT ON

declare @CancellationRestLogID int = -1

Insert into CancelRestaurantLog (RID, NotesToDiner) 
values (@RID, @NotesToDiner)

if @@error = 0
	set @CancellationRestLogID = @@identity

select @CancellationRestLogID

GO

GRANT EXECUTE ON [Admin_Restaurant_Cancel_Log] TO ExecuteOnlyRole

GO