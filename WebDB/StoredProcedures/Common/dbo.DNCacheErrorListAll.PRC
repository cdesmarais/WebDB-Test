if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheErrorListAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheErrorListAll]
GO


--***********************************************
--** REtrieve Error List for all languages
--***********************************************

CREATE PROCEDURE dbo.DNCacheErrorListAll

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT
	ErrorCode, LanguageID, ErrorMessage
	
FROM ErrorMessage
where errorcode is not null

GO


GRANT EXECUTE ON [DNCacheErrorListAll] TO ExecuteOnlyRole

GO
