if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Content_GetReviewer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Content_GetReviewer]
GO




CREATE PROCEDURE dbo.Content_GetReviewer
(
  @metro_ID int
)
AS
SET NOCOUNT ON
SELECT LogoName as Logo_Name from Provider where metroareaid =  @metro_ID
GO

GRANT EXECUTE ON [Content_GetReviewer] TO ExecuteOnlyRole

GO
