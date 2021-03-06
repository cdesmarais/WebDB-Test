


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DeleteGroupIDFrmValueLookup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DeleteGroupIDFrmValueLookup]
GO

create procedure [dbo].[DeleteGroupIDFrmValueLookup]
(
	@ValueID int
	,@LookUpID int
)
AS

--This Proc is used to Search Promos by given ID.

Delete 	
	
from	 
	ValueLookUpIDList

where	 
	LookUpID = @LookUpID
    and ValueID = @ValueID


GO

GRANT EXECUTE ON [DeleteGroupIDFrmValueLookup] TO ExecuteOnlyRole

GO