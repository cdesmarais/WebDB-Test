if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheLanguage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheLanguage]
GO

CREATE Procedure dbo.DNCacheLanguage
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

select 	 
			l.LanguageID,
			l.LanguageCode
from 		Language l
where		l.active = 1

GO

GRANT EXECUTE ON [DNCacheLanguage] TO ExecuteOnlyRole

GO

