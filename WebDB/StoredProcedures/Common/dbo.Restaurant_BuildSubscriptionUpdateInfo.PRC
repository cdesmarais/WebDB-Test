if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_BuildSubscriptionUpdateInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_BuildSubscriptionUpdateInfo]
GO







CREATE PROCEDURE dbo.Restaurant_BuildSubscriptionUpdateInfo
(@RestaurantID int,
 @NetAddress nvarchar(255),
 @Password nvarchar(255)
)
AS
/*created 5-13-02 this sproc will populate the RestaurantEmailSubscriptionNotification table with update
information (possibly several records) for the Restaurant in question... the table will then be used for 
email subscription updates...*/
SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @DEBUGGING int
set @DEBUGGING = 0

declare @CharLimit int
set @CharLimit = 999

declare @lastunsubscribe datetime,@lastsubscribe datetime

select  @lastunsubscribe = LastUnsubNotification,
 	@lastsubscribe = LastSubNotification 
	from RestaurantEmailSubscriptionNotification where
	RID = @RestaurantID

if @lastunsubscribe is null /*then the Restaurant probably hasn't been inserted into the RestaurantEmailSubscriptionNotification table...*/
	BEGIN
	if exists (select RID from Restaurant where RestStateID = 1 and allotment <> 1 and RID = @RestaurantID)
		BEGIN
			--print 'inserting!'
			/*we must insert the Restaurant into the notification table ...*/
			insert into RestaurantEmailSubscriptionNotification 
			(RID,LastSubNotification,LastUnsubNotification)
			values (@RestaurantID,'1900-01-01','1900-01-01')
			
			set @lastunsubscribe = convert(datetime,'1900-01-01')
			set @lastsubscribe = convert(datetime,'1900-01-01')
		END
	else
		BEGIN
		if @DEBUGGING = 1
			print 'restaurant doesn''nt exist!'
		Return (1) /*ie. this Restaurant doesn't need updating... and should never reach here in the first place!*/
		END
	END

--************************
--** TODO: EV: Review -- Changed from 8000 char to 4000
--************************
declare @list nvarchar(4000) /*this should handle at least 200 (40 char) email addresses...*/
declare @p int,@l int,@s int

/* We now insert all UNSUBSCRIBE information for the Restaurant into the EmailSubscriptionUpdates table...*/
 
   set @list = null
 
    select   @list = (coalesce(@list,'')
                     + Email
                     + ',')
                     
    from      EmailSubscrRequests 
	where RequestDate > @lastunsubscribe
	and Send = 0
if @DEBUGGING = 1
	print @list 

set @s = 0if len(@list) > 0
BEGIN
TryAgain:
	set @p = charindex (',',@list)
	if @p = 0
		BEGIN
		/*we must have a single email address so insert into table... this should actually never happen. */
		if @DEBUGGING = 1
			print '@list final is: ' + @list
		goto Done
		END
	else
		BEGIN
			while (@p > 0) and (@p < @CharLimit) and (@s < 20)
				BEGIN
				set @l = @p
				set @p = charindex (',',@list,@l + 1)
				set @s = @s + 1
				End
			/*here we 'send' the unsubscribe information*/
			Insert into EmailSubscriptionUpdates (RID,NetAddress,Pwd,EmailList,Send,UpdateError)
			values (@RestaurantID,@NetAddress,@Password,left(@list,@l),0,0)		

			if @DEBUGGING = 1
				print 'value passed is: ' + left(@list,@l)
			if len(@list) > @l
			BEGIN
			set @list = right(@list,(len(@list) - @l))
			if @DEBUGGING = 1
				print 'new @list: ' + @list
			goto TryAgain
			END
		END
END
Done: 
	if @DEBUGGING = 1
		BEGIN
			print 'done'
			print @l
			print @list
		END


/* We now insert all SUBSCRIBE information for the Restaurant into the EmailSubscriptionUpdates table...*/

   	set @list = null
	set @p = 0
	set @l = 0
	set @s = 0

 
    select   @list = (coalesce(@list,'')
                     + Email
                     + ',')
                     
    from      EmailSubscrRequests 
	where RequestDate > @lastsubscribe
	and Send = 1
if @DEBUGGING = 1
	print @list 

set @s = 0if len(@list) > 0
BEGIN
TryAgain2:
	set @p = charindex (',',@list)
	if @p = 0
		BEGIN
		/*we must have a single email address so insert into table... this should actually never happen. */
		if @DEBUGGING = 1
			print '@list final is: ' + @list
		goto Done2
		END
	else
		BEGIN
			while (@p > 0) and (@p < @CharLimit) and (@s < 20)
				BEGIN
				set @l = @p
				set @p = charindex (',',@list,@l + 1)
				set @s = @s + 1
				End
			/*here we 'send' the unsubscribe information*/
			Insert into EmailSubscriptionUpdates (RID,NetAddress,Pwd,EmailList,Send,UpdateError)
			values (@RestaurantID,@NetAddress,@Password,left(@list,@l),1,0)		

			if @DEBUGGING = 1
				print 'value passed is: ' + left(@list,@l)
			if len(@list) > @l
			BEGIN
			set @list = right(@list,(len(@list) - @l))
			if @DEBUGGING = 1
				print 'new @list: ' + @list
			goto TryAgain2
			END
		END
END
Done2: 
	if @DEBUGGING = 1
		BEGIN
			print 'done2'
			print @l
			print @list
		END
/*create table EmailSubscriptionUpdates
(RID int not null,
 NetAddress nvarchar(40) not null,
 Pwd nvarchar(255) not null default '',
 EmailList nvarchar(999) not null default '',
 Send bit not null,
 UpdateError bit not null default 0)*/

GO

GRANT EXECUTE ON [Restaurant_BuildSubscriptionUpdateInfo] TO ExecuteOnlyRole

GO
