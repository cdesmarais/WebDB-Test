if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetAllROMSRestaurantGroups]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetAllROMSRestaurantGroups]
go

--
-- Return all restaurant groups
-- TT 22722 mmc
-- 
CREATE PROC [dbo].[Admin_GetAllROMSRestaurantGroups]
AS

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT	*
	FROM	RestaurantGroup
	ORDER BY LTRIM(GroupName) ASC -- don't sort on leading spaces, but don't delete 'em

GO

GRANT EXECUTE ON [Admin_GetAllROMSRestaurantGroups] TO ExecuteOnlyRole

GO
