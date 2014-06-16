if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTRecordAlertNotification]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTRecordAlertNotification]
GO

-- Updates elements of the alert. All elements except the alertid can be null..
CREATE PROCEDURE dbo.OTRecordAlertNotification
(
	@theAlertID int,
	@notificationSentDateTS datetime	
)
AS

declare @theSentCount int,@theTierThreshold int,@tierFamilyID int,@tierNum int

-- if a notification was sent perform updates..also do escalation logic..
if @notificationSentDateTS is not null
BEGIN
	-- update last notification sent time and sent notification count, also update status to "notification sent"
	update otalerts set LastNotifyDateTS = @notificationSentDateTS,NotificationSentCount=(NotificationSentCount+1)
	where alertid=@theAlertID and status <> 2

	-- do we need to escalate this item?
	select @theSentCount=a.notificationsentcount,@theTierThreshold=t.escalationthreshold,@tierFamilyID=t.tierfamilyid,@tierNum=t.tier from 
	otalerts a,otalerttiers t where a.tierid = t.alerttierid and a.alertid=@theAlertID

	-- if escalation threshold is zero - you are already at highest level of escalation! 
	-- if notifications sent are higher than threshold - then escalate.
	if @theTierThreshold <> 0 AND @theSentCount > @theTierThreshold
	BEGIN
		update otalerts set tierid = (select top 1 alerttierid from otalerttiers where tierfamilyid=@tierFamilyID and tier > @tierNum order by tier asc)
		where alertid=@theAlertID and status <> 2		
	END
	
END


GO

GRANT EXECUTE ON [OTRecordAlertNotification] TO ExecuteOnlyRole

GO
