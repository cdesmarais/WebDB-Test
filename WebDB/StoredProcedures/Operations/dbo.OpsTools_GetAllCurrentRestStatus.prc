IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OpsTools_GetAllCurrentRestStatus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[OpsTools_GetAllCurrentRestStatus]
GO

CREATE PROCEDURE [dbo].[OpsTools_GetAllCurrentRestStatus]
AS
BEGIN
      -- =============================================
      -- Author:        Chuck Desmarais
      -- Create date:	3/9/2011
      -- Description:   This procedure returns the current status and metro for all restaurants
      --				It is called by ops tools for generating reports and alerts based on online/offline
      -- =============================================
      SET NOCOUNT ON
      SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SELECT            r.RID
                        ,CASE 
                              WHEN r.RestStateID = 1 AND isReachable = 1 THEN 'Reserve Now'
                              WHEN r.RestStateID = 1 AND isReachable = 0 THEN 'Back Soon'
                              ELSE RState.RState
                        END as Restaurant_status
      from        restaurantVW r
      INNER JOIN  Restaurantstate RState
      ON                r.RestStateID   = RState.RestStateID
END

GO

GRANT EXECUTE ON [dbo].[OpsTools_GetAllCurrentRestStatus] TO [ExecuteOnlyRole] 
GO

GRANT EXECUTE ON [dbo].[OpsTools_GetAllCurrentRestStatus] TO [Ops_User] 
GO


