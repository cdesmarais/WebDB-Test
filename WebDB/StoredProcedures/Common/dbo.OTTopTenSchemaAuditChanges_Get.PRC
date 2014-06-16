if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTTopTenSchemaAuditChanges_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTTopTenSchemaAuditChanges_Get]
GO


create procedure [dbo].[OTTopTenSchemaAuditChanges_Get] 
as

	select	ottoptenschemaauditid
			,metroareaid
			,cuisineid
			,macroid
			,operationtypeid
			,createdt
	from	ottoptenschemaaudit
	where	processdt is null

GO

GRANT EXECUTE ON [OTTopTenSchemaAuditChanges_Get] TO ExecuteOnlyRole

GO
