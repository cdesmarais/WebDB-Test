/* 
	Note: this procedure is being replaced by User_UnsubscribeEmail for the 2011 WR2 release. It can be removed sometime after the WR2 release
	Note2: this procedure has been updated to be compatible with 2011 WR2 schema changes, but in so doing
	behavior has been changed so that if @isSubscribe bit is 1, procedure has no effect at all.  
	(Previous behavior:  if @isSubscribe = 1, user is subscribed to all emails.)
	Essential behavior when @isSubscribe = 0 remains unchanged (unsubscribes for a particular newletter,
	regardless of location).
*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_ManageEmailSubscriptions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_ManageEmailSubscriptions]
GO

CREATE Procedure dbo.User_ManageEmailSubscriptions
 (
  @UserID int,  
  @MessageType char(2),
  @isSubscribe BIT,
  @isCallerorAdmin bit  
 )
As

SET NOCOUNT ON


declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int

declare @MetroAreaID int

declare @UnsubscribeInsider bit
declare @UnsubscribeSpotlight bit
declare @UnsubscribeNewHot bit
declare @UnsubscribeDinerChoice bit
declare @UnsubscribeRW bit
declare @UnsubscribePromo bit
declare @UnsubscribeProduct bit

set @ProcName = 'User_ManageEmailSubscriptions'

BEGIN TRAN

set @UnsubscribeInsider = 0
set @UnsubscribeSpotlight = 0
set @UnsubscribeNewHot = 0
set @UnsubscribeDinerChoice = 0
set @UnsubscribeRW = 0
set @UnsubscribePromo = 0
set @UnsubscribeProduct = 0

IF (@isCallerorAdmin = 0)	-- customer
BEGIN
	SELECT @MetroAreaID = MetroAreaID from Customer where CustID = @UserID
	IF NOT EXISTS (SELECT * FROM UserOptIn WHERE CustID = @UserID and MetroAreaID = @MetroAreaID)
	begin
		set @Action = 'Insert customer into UserOptIn table'
		INSERT INTO UserOptIn (CustID, MetroAreaID) VALUES (@UserID, @MetroAreaID)
	end
END 
ELSE IF (@isCallerorAdmin = 1)
BEGIN	
	SELECT @MetroAreaID = MetroAreaID from Caller where CallerID = @UserID 
	IF NOT EXISTS (SELECT * FROM UserOptIn WHERE CallerID = @UserID and MetroAreaID = @MetroAreaID)
	begin
		set @Action = 'Insert customer into UserOptIn table'
		INSERT INTO UserOptIn (CallerID, MetroAreaID) VALUES (@UserID, @MetroAreaID)
	end
	END
	
set @Action = 'Update User Email Preference'
IF (@MessageType = 'in')
	set @UnsubscribeInsider = ~@isSubscribe 
	ELSE IF (@MessageType = 'nh')
	set @UnsubscribeNewHot = ~@isSubscribe 
	ELSE IF (@MessageType = 'dc')
    set @UnsubscribeDinerChoice = ~@isSubscribe 
	ELSE IF (@MessageType = 'rw')
	set @UnsubscribeRW = ~@isSubscribe 
	ELSE IF (@MessageType = 'pc')
	set @UnsubscribePromo = ~@isSubscribe 
	ELSE IF (@MessageType = 'sl')
	set @UnsubscribeSpotlight = ~@isSubscribe 
	ELSE IF (@MessageType = 'pd')
	set @UnsubscribeProduct = ~@isSubscribe 

exec User_UnsubscribeEmail_v2 @UserID,	@isCallerorAdmin, @UnsubscribeInsider, @UnsubscribeSpotlight, @UnsubscribeNewHot, @UnsubscribeDinerChoice, @UnsubscribeRW, @UnsubscribePromo, @UnsubscribeProduct

set @DBError = @@error
if @DBError <> 0
	goto general_error

COMMIT TRAN
RETURN(0)

general_error:
	rollback transaction
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	return(0)
GO

GRANT EXECUTE ON [User_ManageEmailSubscriptions] TO ExecuteOnlyRole
GO
