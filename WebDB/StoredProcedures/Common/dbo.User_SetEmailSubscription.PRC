if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_SetEmailSubscription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_SetEmailSubscription]
GO




CREATE PROCEDURE dbo.User_SetEmailSubscription
(@email nvarchar(255)
,@send int)

AS
if exists (select email from EmailSubscrRequests
where email = @email)
	update EmailSubscrRequests set send = @send,requestdate = getdate()
	where email = @email
else
	insert into EmailSubscrRequests(email,send,requestdate)
	values (@email,@send,getdate())
GO

GRANT EXECUTE ON [User_SetEmailSubscription] TO ExecuteOnlyRole

GO
