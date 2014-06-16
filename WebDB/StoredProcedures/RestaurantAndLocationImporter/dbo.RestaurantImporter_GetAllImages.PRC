if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantImporter_GetAllImages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantImporter_GetAllImages]
GO

CREATE Procedure dbo.RestaurantImporter_GetAllImages

As
SET NOCOUNT ON
set transaction isolation level read uncommitted
SELECT
	RID,
    ShowImage,
    ImageName
FROM 
	RestaurantImage

GO

GRANT EXECUTE ON [RestaurantImporter_GetAllImages] TO ExecuteOnlyRole

GO


