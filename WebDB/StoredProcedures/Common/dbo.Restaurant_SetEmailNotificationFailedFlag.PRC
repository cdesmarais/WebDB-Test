if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_SetEmailNotificationFailedFlag]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_SetEmailNotificationFailedFlag]
GO




CREATE PROCEDURE dbo.Restaurant_SetEmailNotificationFailedFlag
(@RestaurantID int
,@Send int)
AS
update EmailSubscriptionUpdates set UpdateError = 1 
where RID = @RestaurantID 
and Send = @Send
GO

GRANT EXECUTE ON [Restaurant_SetEmailNotificationFailedFlag] TO ExecuteOnlyRole

GO
