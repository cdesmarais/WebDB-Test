IF EXISTS (
    SELECT * 
    FROM dbo.sysobjects 
    WHERE
        id = object_id(N'[dbo].[TimeZoneImporter_GetAll]') 
        AND 
        OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
    DROP PROCEDURE [dbo].[TimeZoneImporter_GetAll]
END
GO

CREATE PROCEDURE dbo.TimeZoneImporter_GetAll 
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 
	TZID as TimeZoneId,
	SupportsDST
FROM
	[TimeZone]

GO

GRANT EXECUTE ON [TimeZoneImporter_GetAll] TO ExecuteOnlyRole

GO
