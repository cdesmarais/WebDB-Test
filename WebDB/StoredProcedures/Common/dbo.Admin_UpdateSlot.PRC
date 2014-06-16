if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdateSlot]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdateSlot]
GO



CREATE PROCEDURE dbo.Admin_UpdateSlot

(@slot_time DateTime,
 @Min_Size int,
 @Max_Size int,
 @slot_ID int
 )

AS
SET NOCOUNT ON

update ReservationTemplate set SlotTime = @slot_time,SizeMin=@Min_Size,SizeMax=@Max_Size where SlotID = @slot_ID
GO

GRANT EXECUTE ON [Admin_UpdateSlot] TO ExecuteOnlyRole

GO
