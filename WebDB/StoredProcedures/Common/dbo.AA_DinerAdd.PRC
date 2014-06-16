if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AA_DinerAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AA_DinerAdd]
GO


CREATE PROCEDURE  dbo.AA_DinerAdd

@Email nvarchar(255),
@FirstName nvarchar(255),
@LastName nvarchar(255),
@ContactPhone nvarchar(24),
@PhoneExtension nvarchar(6),
@CallerID int,
@retval int = 0 OUTPUT

AS
SET NOCOUNT ON

--**************************************************************************************
--** Begin OBOSLETE LOG
--** The following will log the fact that this obsolete proc was exectured into LogDB..ErrorLog
--** This snippet can be cut and pasted in to any block of code that is thought to be obsolete
--** Embedded in WR9 2010
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

-- Check if the caller Id is valid
-- If callerId 0 then previous call to AA_CallerAdd Failed and this proc should not continue
if @CallerID = 0
	return(0)
 
DECLARE @UserID int,@n tinyint,@CreditCardID int,@CustID int,@TranName nvarchar(20)
Select @TranName = 'MyTransaction'
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION @TranName

--1. INSERT NEW CallerCustomer

	INSERT INTO CallCusNextID (CustomerType) VALUES ('S')
	IF (@@ERROR <> 0) Goto general_error

	Select @CustID = scope_identity()

	Insert into CallerCustomer (CustID,FName,LName,ContactPhone,PhoneExt,CallerID,Email, Active) 
    	values (@CustID,@FirstName,@LastName,@ContactPhone,@PhoneExtension,@CallerID,@Email,1)

	IF (@@ERROR <> 0) Goto general_error

--3. CustomerPhone insert
	if @ContactPhone is not null
	BEGIN
		Insert into CustomerPhone (PhoneTypeID,CustID,Phone) values (5,@CustID,@ContactPhone)
		IF (@@ERROR <> 0) Goto general_error 
	END

COMMIT TRANSACTION @TranName
RETURN(0)

general_error:
ROLLBACK TRANSACTION @TranName
RAISERROR('6',17,1)
RETURN(2)
GO


GRANT EXECUTE ON [AA_DinerAdd] TO ExecuteOnlyRole

GO
