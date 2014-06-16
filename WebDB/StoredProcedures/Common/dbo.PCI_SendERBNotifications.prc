

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PCI_SendERBNotifications]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PCI_SendERBNotifications]
go

create procedure dbo.PCI_SendERBNotifications
(
	@parRID  int
	,@parPCIEnabledKey nvarchar(500)
	,@parPCIEnabledVal nvarchar(500)
	,@parPCIKeyIdKey nvarchar(500)
	,@parPCIKeyIdVal nvarchar(500)
	,@parPCIKeyKey nvarchar(500)
	,@parPCIKeyVal nvarchar(500)
	,@parPCIMerchantIdKey nvarchar(500)
	,@parPCIMerchantIdVal nvarchar(500)
	,@parSendAllkeys int
	,@parReason nvarchar(500)
)

as  
/* PCI : Stored procedure used to send ERB notifications  */
declare @DBError int

BEGIN TRANSACTION

	exec dbo.SvcSetValEnqueue @parRID,@parPCIEnabledKey,@parPCIEnabledVal,@parReason

	set @DBError = @@error
	if @DBError <> 0
		goto general_error

	/* When opt out operation is performed and if send all keys flag is set then only send 
		all other keys  */
	if(@parPCIEnabledVal = '1' or @parSendAllkeys = 1) 
	begin
		exec dbo.SvcSetValEnqueue @parRID,@parPCIKeyIdKey,@parPCIKeyIdVal,@parReason	
		set @DBError = @@error
		if @DBError <> 0
			goto general_error

		exec dbo.SvcSetValEnqueue @parRID,@parPCIKeyKey,@parPCIKeyVal,@parReason
		set @DBError = @@error
		if @DBError <> 0
			goto general_error

		exec dbo.SvcSetValEnqueue @parRID,@parPCIMerchantIdKey,@parPCIMerchantIdVal,@parReason
		set @DBError = @@error
		if @DBError <> 0
			goto general_error
	end

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION	
	Return(0)
go

GRANT EXECUTE ON [PCI_SendERBNotifications] TO ExecuteOnlyRole
go


