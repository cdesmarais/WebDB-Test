/* 
	Note: this procedure was found to be unreferenced by any code as of 1/2011.  Consequently, it has been marked as obsolete.
*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_ConvertAnon]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_ConvertAnon]
GO

CREATE Procedure dbo.User_ConvertAnon
 (
  @Customer_ID int,
  @oldpassword nvarchar(50),
  @newpassword nvarchar(50),
  @isAdmin int
  )
As
SET NOCOUNT ON

--**************************************************************************************
--** Begin OBSOLETE LOG
--** The following will log the fact that this obsolete proc was exectured into LogDB..ErrorLog
--** This snippet can be cut and pasted in to any block of code that is thought to be obsolete
--** Embedded in WR12 2011
--**************************************************************************************
	declare @_ErrorMessage nvarchar(1000)
	set @_ErrorMessage = 'PROC called'

	declare @_objName nvarchar(1000)
	SELECT	@_objName = OBJECT_NAME(@@PROCID), 
			@_ErrorMessage = @_ErrorMessage 
							+ ': '+ @_objName
							+ '  by host: ' + rtrim(isnull(hostname, 'unknown'))
							+ '  User: ' + rtrim(isnull(loginame, 'unknown'))
	FROM	sys.sysprocesses 
	WHERE	spid = @@spid  
	exec procLogProcedureError 9, @_objName, 'OBSOLETE', @_ErrorMessage
--**************************************************************************************
--** End OBOSLETE LOG
--**************************************************************************************

BEGIN TRAN

Declare @UserEmail nvarchar(50),@ConsumerType int,@HasBeenConverted int,@Caller_ID int
DECLARE @MetroAreaID int

Set @HasBeenConverted = 0

Select @UserEmail = email,@ConsumerType = ConsumerType, @MetroAreaID = MetroAreaID from Customer where CustID = @Customer_ID
if right(@UserEmail,8) = 'isAAUser'
BEGIN
	Set @HasBeenConverted = 1
END	

--See if accoount has been converted to regular user,if not convert

if exists(Select CustID from Customer where CustID = @Customer_ID and ConsumerType = 8) and @HasBeenConverted = 0
BEGIN


	-- 1/6/2005 CK - pull points from promo table
	Declare @RegPromoId int, @RegPoints int
	exec DNGetRegPoints @RegPromoId out, @RegPoints out
  
	Update Customer set ConsumerType = 1,points = @RegPoints,SendAnnouncements = 1 where CustID = @Customer_ID
	
	if (IsNull(@RegPoints,0) > 0)
		Exec User_Add_PromoData @Customer_ID,0,@RegPoints,1,1
	
	Update Reservation set ResPoints = 0 where CustID = @Customer_ID and RStateID <> 1
	
	if (@@error <> 0)
		GOTO general_error

	if @isAdmin = 1
	BEGIN
		Exec ChangeRealCustomerToAAUser @CustomerEmail = @UserEmail
		if (@@error <> 0)
			GOTO general_error
		Select @Caller_ID = CallerID from Caller where email = @UserEmail

		Exec User_Convert_Consumer_Type @Customer_ID = null,@Caller_ID = @Caller_ID,@Original_Consumer_Type_ID = 8,@New_Consumer_Type_ID = 1

		if (@@error <> 0)
			GOTO general_error
			

		Select CallerID as UserID,email,FName as First_Name,1 as Updated from Caller where email = @UserEmail

	
	END
	else
	BEGIN

		Exec User_Convert_Consumer_Type @Customer_ID = @Customer_ID,@Caller_ID = null,@Original_Consumer_Type_ID = 8,@New_Consumer_Type_ID = 1

		if (@@error <> 0)
			GOTO general_error
			
		IF NOT EXISTS(Select CustID FROM UserOptIn with (nolock) WHERE CustID=@Customer_ID and MetroAreaID = @MetroAreaID)
			INSERT INTO UserOptIn (CustID,MetroAreaID) 
				VALUES (@Customer_ID,@MetroAreaID)

		Select CustID as UserID,email,FName as First_Name,1 as Updated from Customer where CustID = @Customer_ID
	
	END

	if (@@error <> 0)
		GOTO general_error

END

else
	
GOTO been_converted



COMMIT TRAN
RETURN(0)

general_error:
ROLLBACK TRAN
RAISERROR('143',16,1)
RETURN(1)

been_converted:
ROLLBACK TRAN
RAISERROR('142',16,1)
RETURN(1)
GO

GRANT EXECUTE ON [User_ConvertAnon] TO ExecuteOnlyRole

GO
