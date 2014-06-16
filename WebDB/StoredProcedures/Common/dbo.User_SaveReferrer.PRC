if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_SaveReferrer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_SaveReferrer]
GO

CREATE PROCEDURE dbo.User_SaveReferrer 
(
@ReferrerID int,
@CustomerID int,
@CallerID int,
@retval int OUTPUT
)
AS
SET NOCOUNT ON
Declare @gobalError int

Begin Tran

if exists (select referrerID from referrer where referrerID = @ReferrerID)
BEGIN
	if @CustomerID > 0
	     Begin
		if not exists(Select CustID from ReferrerRegistration
		where CustID = @CustomerID)
		BEGIN
		     Insert into ReferrerRegistration (ReferrerID,CustID)
		     values (@ReferrerID,@CustomerID)
		END
		set @gobalError = @@ERROR
		IF @gobalError <> 0 GOTO nogood
	     End
	if @CallerID > 0
	     Begin
		if not exists(Select CallerID from ReferrerRegistration
		where CallerID = @CallerID)
		BEGIN
		     Insert into ReferrerRegistration (ReferrerID,CallerID)
		     values (@ReferrerID,@CallerID)
		END
		set @gobalError = @@ERROR
		IF @gobalError <> 0 GOTO nogood
	     End
END
if (@gobalError <> 0) goto nogood
SELECT @retval= 1
commit
RETURN(1)
nogood:
	Rollback

	declare @ErrorMsg as nvarchar(4000)
	set @ErrorMsg = ' @ReferrerID: '+cast(ISNull(@ReferrerID, '') as nvarchar(10))+ ' @CustomerID : '+ cast(ISNULL(@CustomerID, '')  as nvarchar(20)) +' @CallerID: '+cast(ISNULL(@CallerID, '') as nvarchar(10)) + ' Error: ' + convert(nvarchar, @gobalError)
	exec DNErrorAdd 555, 'User_SaveReferrer', @ErrorMsg , 1

	RETURN(0)
GO

GRANT EXECUTE ON [User_SaveReferrer] TO ExecuteOnlyRole

GO
