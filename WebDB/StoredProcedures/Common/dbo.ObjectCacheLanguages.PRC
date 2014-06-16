if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheLanguages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheLanguages]
GO

CREATE Procedure dbo.ObjectCacheLanguages
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

select 	 
			l.LanguageID,
			l.LanguageCode,
			l.active
from 		Language l	

GO

GRANT EXECUTE ON [ObjectCacheLanguages] TO ExecuteOnlyRole

GO
