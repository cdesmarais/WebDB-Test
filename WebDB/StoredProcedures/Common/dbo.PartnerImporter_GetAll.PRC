IF EXISTS (
    SELECT * 
    FROM dbo.sysobjects 
    WHERE
        id = object_id(N'[dbo].[PartnerImporter_GetAll]') 
        AND 
        OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
    DROP PROCEDURE [dbo].[PartnerImporter_GetAll]
END
GO

CREATE PROCEDURE dbo.PartnerImporter_GetAll 
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 
	  PartnerId
	, PartnerName
	, NoPointsMessage
	, CoBrandEmail
FROM
	[Partner]

GO

GRANT EXECUTE ON [PartnerImporter_GetAll] TO ExecuteOnlyRole

GO


