if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LocationImporter_GetAllAreas]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[LocationImporter_GetAllAreas]
GO

CREATE Procedure dbo.LocationImporter_GetAllAreas

As
SET NOCOUNT ON
set transaction isolation level read uncommitted

select 
  StateID
 ,CountryID
 ,StateName
from StateName

GO

GRANT EXECUTE ON [LocationImporter_GetAllAreas] TO ExecuteOnlyRole

GO


