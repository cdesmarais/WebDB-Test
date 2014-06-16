
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTTopTenSchemaAudit_MarkProcessed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTTopTenSchemaAudit_MarkProcessed]
GO


create procedure [dbo].[OTTopTenSchemaAudit_MarkProcessed] 
(
@maxauditid int
)
as

	set nocount on	
	declare @timestamp datetime
	
	if(@maxauditid is null)
	begin
		RAISERROR('MaxAuditID cannot be null',17,1)
		return
	end
	
	set @timestamp = GETDATE()
		
	update	ottoptenschemaaudit
	set		processdt =	@timestamp
	where	OTTopTenSchemaAuditID <= @maxauditid
	and		processdt is null
GO

GRANT EXECUTE ON [OTTopTenSchemaAudit_MarkProcessed] TO ExecuteOnlyRole

GO
