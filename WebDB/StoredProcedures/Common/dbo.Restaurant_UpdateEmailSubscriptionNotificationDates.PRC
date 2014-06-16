if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_UpdateEmailSubscriptionNotificationDates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_UpdateEmailSubscriptionNotificationDates]
GO




CREATE PROCEDURE dbo.Restaurant_UpdateEmailSubscriptionNotificationDates
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/*created 5/15/02 ... this sproc will update the appropriate 'last notified' fields for restaurants which have been successfully 
updated...*/

update RestaurantEmailSubscriptionNotification set LastSubNotification = getdate()
where RID in (select distinct RID from EmailSubscriptionUpdates where Send = 1 and UpdateError = 0)

update RestaurantEmailSubscriptionNotification set LastUnsubNotification = getdate()
where RID in (select distinct RID from EmailSubscriptionUpdates where Send = 0 and UpdateError = 0)
GO

GRANT EXECUTE ON [Restaurant_UpdateEmailSubscriptionNotificationDates] TO ExecuteOnlyRole

GO
