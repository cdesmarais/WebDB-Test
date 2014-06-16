if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Content_GetLogos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Content_GetLogos]
GO




CREATE PROCEDURE dbo.Content_GetLogos
AS
SET NOCOUNT ON
SELECT LogoName as Logo_Name
FROM Provider
GO

GRANT EXECUTE ON [Content_GetLogos] TO ExecuteOnlyRole

GO
