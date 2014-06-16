if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_BlockDays_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_BlockDays_Delete]
GO


CREATE PROCEDURE dbo.Admin_BlockDays_Delete 

@restaurant_id int,
@UnblockAll int,
@Assignment_Date datetime

AS

if @UnblockAll = 1 
	BEGIN
	Delete from BlockedDay where RID = @restaurant_id
	END
else
	BEGIN
	Delete from blockedDay where  RID = @restaurant_id and BlockedDate = @Assignment_Date
	END



GO

GRANT EXECUTE ON [Admin_BlockDays_Delete] TO ExecuteOnlyRole

GO
