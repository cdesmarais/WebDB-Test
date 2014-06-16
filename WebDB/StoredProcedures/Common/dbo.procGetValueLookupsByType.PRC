
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procGetValueLookupsByType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procGetValueLookupsByType]
GO

CREATE PROCEDURE dbo.procGetValueLookupsByType
@LookupType nvarchar(25)
AS

set nocount on
set transaction isolation level read uncommitted

select		LKey
			,ValueInt
			,ValueDT
			,ValueChar
from 		ValueLookup 
where 		LType = upper(@LookupType)
order by	LKey

GO

GRANT EXECUTE ON [procGetValueLookupsByType] TO ExecuteOnlyRole

GO
