if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_SetEmailNotificationFlag]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_SetEmailNotificationFlag]
GO

CREATE PROCEDURE dbo.Restaurant_SetEmailNotificationFlag
(@RID int
, @Sucess int)
As
Set nocount on
set transaction isolation level read uncommitted
if @Sucess = 0
	update emailsubscriptionupdates set UpdateError = 1
	where RID = @RID
else
	update  emailsubscriptionupdates set UpdateError = 0
	where RID = @RID
GO

GRANT EXECUTE ON [Restaurant_SetEmailNotificationFlag] TO ExecuteOnlyRole

GO
