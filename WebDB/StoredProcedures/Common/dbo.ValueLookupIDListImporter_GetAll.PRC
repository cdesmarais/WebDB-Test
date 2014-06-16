IF EXISTS (
    SELECT * 
    FROM dbo.sysobjects 
    WHERE
        id = object_id(N'[dbo].[ValueLookupIDListImporter_GetAll]') 
        AND 
        OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
    DROP PROCEDURE [dbo].[ValueLookupIDListImporter_GetAll]
END
GO

CREATE PROCEDURE dbo.ValueLookupIDListImporter_GetAll
	@LookupIds NVARCHAR(4000)
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT
	LookupId,
	ValueId
FROM [ValueLookupIDList]
INNER JOIN dbo.fStringsToTab(@LookupIds, ',') s ON LookupId = s.StringValues

GO

GRANT EXECUTE ON [ValueLookupIDListImporter_GetAll] TO ExecuteOnlyRole

GO