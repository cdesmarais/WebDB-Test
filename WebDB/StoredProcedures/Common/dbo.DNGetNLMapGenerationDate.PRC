if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetNLMapGenerationDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetNLMapGenerationDate]
GO

CREATE PROCEDURE dbo.DNGetNLMapGenerationDate
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT [ValueDT] 
FROM  [dbo].[ValueLookup]
WHERE LType = 'ISAPIWEB' AND LKey = 'NLMapFileGenerationDate'
GO

GRANT EXECUTE ON [DNGetNLMapGenerationDate] TO ExecuteOnlyRole
GO