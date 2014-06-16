if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_UnsubscribeEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_UnsubscribeEmail]
GO


create procedure dbo.User_UnsubscribeEmail
(
	@UserID int,	
	@isCallerorAdmin bit,
	@UnsubscribeInsider bit,
	@UnsubscribeSpotlight bit,
	@UnsubscribeNewHot bit,
	@UnsubscribeDinerChoice bit,
	@UnsubscribeRW bit,
	@UnsubscribePromo bit
)
	
as
SET NOCOUNT ON

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError INT
set @ProcName = 'User_UnsubscribeEmail'

BEGIN TRAN

IF (@isCallerorAdmin = 0)	-- customer
BEGIN
	set @Action = 'Update Customer Email Preference'	
	
	IF (@UnsubscribeInsider = 1)
	BEGIN
		UPDATE	UserOptIn SET Insider = 0, UpdatedDtUTC = getutcdate() 
		WHERE	CustID = @UserID AND Insider <> 0
	END 
	
	IF (@UnsubscribeNewHot = 1)
	BEGIN
		UPDATE	UserOptIn SET NewHot = 0, UpdatedDtUTC = getutcdate() 
		WHERE	CustID = @UserID AND NewHot <> 0
	END
	
	IF (@UnsubscribeDinerChoice=1)
	BEGIN
		UPDATE	UserOptIn SET DinersChoice = 0, UpdatedDtUTC = getutcdate() 
		WHERE	CustID = @UserID AND DinersChoice <> 0
	END
	
	IF (@UnsubscribeRW = 1)
	BEGIN
	UPDATE	UserOptIn SET RestaurantWeek = 0, UpdatedDtUTC = getutcdate() 
	WHERE	CustID = @UserID AND RestaurantWeek <> 0
	END
	
	IF (@UnsubscribePromo = 1)
	BEGIN
		UPDATE	UserOptIn SET Promotional = 0, UpdatedDtUTC = getutcdate() 
		WHERE	CustID = @UserID AND Promotional <> 0
	END
	
	IF (@UnsubscribeSpotlight =1)
	BEGIN
		UPDATE	UserOptIn SET Spotlight = 0, UpdatedDtUTC = getutcdate() 
		WHERE	CustID = @UserID AND Spotlight <> 0
	END 
END
ELSE IF (@isCallerorAdmin = 1)
BEGIN

	set @Action = 'Update Caller Email Preference'
	
	IF (@UnsubscribeInsider = 1)
	BEGIN
		UPDATE	UserOptIn SET Insider = 0, UpdatedDtUTC = getutcdate() 
		WHERE	CallerID = @UserID AND Insider <> 0
	END 
	
	IF (@UnsubscribeNewHot = 1)
	BEGIN
		UPDATE	UserOptIn SET NewHot = 0, UpdatedDtUTC = getutcdate() 
		WHERE	CallerID = @UserID AND NewHot <> 0
	END 
	
	IF (@UnsubscribeDinerChoice = 1)
	BEGIN
		UPDATE	UserOptIn SET DinersChoice = 0, UpdatedDtUTC = getutcdate() 
		WHERE	CallerID = @UserID AND DinersChoice <> 0
	END 
	
	IF (@UnsubscribeRW = 1)
	BEGIN
		UPDATE	UserOptIn SET RestaurantWeek = 0, UpdatedDtUTC = getutcdate() 
		WHERE	CallerID = @UserID AND RestaurantWeek <> 0
	END 

	IF (@UnsubscribePromo = 1)
	BEGIN
		UPDATE	UserOptIn SET Promotional = 0, UpdatedDtUTC = getutcdate() 
		WHERE	CallerID = @UserID AND Promotional <> 0
	END 
	
	IF (@UnsubscribeSpotlight=1)
	BEGIN
		UPDATE	UserOptIn SET Spotlight = 0, UpdatedDtUTC = getutcdate() 
		WHERE	CallerID = @UserID AND Spotlight <> 0
	END 
	
END


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

GRANT EXECUTE ON [User_UnsubscribeEmail] TO ExecuteOnlyRole

GO




