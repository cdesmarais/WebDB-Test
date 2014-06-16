if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNValueIDLookups]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNValueIDLookups]
GO

Create procedure dbo.DNValueIDLookups
AS

set transaction isolation level read uncommitted

SELECT IL.LookupID, IL.ValueID 
FROM ValueLookupIDList IL
INNER JOIN ValueLookupMaster VM
ON IL.LookupID = VM.LookupID
WHERE VM.TYPE = 'WEBSERVER'

GO

GRANT EXECUTE ON [dbo].[DNValueIDLookups] TO ExecuteOnlyRole

GO
