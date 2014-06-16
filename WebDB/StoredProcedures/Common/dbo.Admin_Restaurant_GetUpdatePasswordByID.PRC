if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetUpdatePasswordByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetUpdatePasswordByID]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetUpdatePasswordByID
 (
  @RestaurantID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	r.RName AS RestaurantName,
		r.UpdatePwd AS UpdatePassword
FROM	RestaurantVW r
WHERE	(r.RID = @RestaurantID)

GO

GRANT EXECUTE ON [Admin_Restaurant_GetUpdatePasswordByID] TO ExecuteOnlyRole

GO
