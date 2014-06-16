if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant2_SetEmailNotificationFlag]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant2_SetEmailNotificationFlag]
GO

CREATE PROCEDURE dbo.Restaurant2_SetEmailNotificationFlag
(@RID int
, @Sucess int)
As
Set nocount on
set transaction isolation level read uncommitted
if @Sucess = 0
	update temp_emailsubscriptionupdates set UpdateError = 1
	where RID = @RID
else
	update  temp_emailsubscriptionupdates set UpdateError = 0
	where RID = @RID
GO

GRANT EXECUTE ON [Restaurant2_SetEmailNotificationFlag] TO ExecuteOnlyRole

GO
