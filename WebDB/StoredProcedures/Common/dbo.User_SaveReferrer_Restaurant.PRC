if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_SaveReferrer_Restaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_SaveReferrer_Restaurant]
GO



CREATE Procedure dbo.User_SaveReferrer_Restaurant
(
@Restaurant_ID nvarchar(255),
@CustomerID int,
@CallerID int,
@retval int OUTPUT
)
AS
SET NOCOUNT ON
Declare @gobalError int

Begin Tran
if @CustomerID > 0
     Begin
	if not exists(Select CustID from ReferrerRestaurantRegistration
	where CustID = @CustomerID)
	BEGIN
	     Insert into ReferrerRestaurantRegistration (RID,CustID)
	     values (@Restaurant_ID,@CustomerID)
		 set @gobalError = @@ERROR
		 IF @gobalError <> 0 GOTO nogood
	END
     End
     if @CallerID > 0
     Begin
	if not exists(Select CallerID from ReferrerRestaurantRegistration
	where CallerID = @CallerID)
	BEGIN
	     Insert into ReferrerRestaurantRegistration (RID,CallerID)
	     values (@Restaurant_ID,@CallerID)     
		 set @gobalError = @@ERROR
		 IF @gobalError <> 0 GOTO nogood
	END
     End
     if (@gobalError <> 0) goto nogood
SELECT @retval= 1
commit
RETURN(1)
nogood:
	Rollback
	
	declare @ErrorMsg as nvarchar(4000)
	set @ErrorMsg = ' @Restaurant_ID: ' + ISNULL(@Restaurant_ID, '') + ' @CustomerID : '+ cast(ISNULL(@CustomerID, '')  as nvarchar(20)) +' @CallerID: '+cast(ISNULL(@CallerID, '') as nvarchar(10)) + ' Error: ' + convert(nvarchar, @gobalError)
	
	exec DNErrorAdd 555, 'User_SaveReferrer_Restaurant', @ErrorMsg , 1
	
	RETURN(0)
GO

GRANT EXECUTE ON [User_SaveReferrer_Restaurant] TO ExecuteOnlyRole

GO
