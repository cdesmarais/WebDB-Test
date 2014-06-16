if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcPJRGetValueLookupConfig]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcPJRGetValueLookupConfig]
GO

CREATE PROCEDURE [dbo].[svcPJRGetValueLookupConfig]

AS

/*
This procedure returns valuelookup configs that will be accessed by PJR job.
*/

--Get the ValueLookup configs 
select	LKey,
		ValueInt,
		ValueChar,
		ValueDT
from	ValueLookup 
where LType = 'EVENTHORIZON'

GO

GRANT EXECUTE ON [svcPJRGetValueLookupConfig] TO ExecuteOnlyRole

GO

