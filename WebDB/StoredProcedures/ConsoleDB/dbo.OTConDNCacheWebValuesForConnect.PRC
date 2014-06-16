
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConDNCacheWebValuesForConnect]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConDNCacheWebValuesForConnect]
GO

-- Derived from DNCacheWebValues, retrieves only those values that are needed by Connect
-- TODO:  Consider adding a "for Connect" flag to the ValueLookup table so this lookup 
--        can be more efficient

CREATE PROCEDURE dbo.OTConDNCacheWebValuesForConnect
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	LKey,
		ValueInt,
		ValueDT,
		ValueChar
FROM	ValueLookup 
WHERE	LType = 'WEBSERVER'
AND		(LKey = 'ENABLE_FIELDTEST_RIDS'
OR		 LKey = 'OTC_REMOTE_AUTH_URL' 
OR		 LKey = 'OTC_DAYBEHIND_TIMEOUT'  
OR		 LKey = 'OTC_INTERNAL_LOGIN')  -- this needs to be modified to add new ValueLookup values for Connect
GO

GRANT EXECUTE ON [OTConDNCacheWebValuesForConnect] TO ConsoleExecuteRole

GO

