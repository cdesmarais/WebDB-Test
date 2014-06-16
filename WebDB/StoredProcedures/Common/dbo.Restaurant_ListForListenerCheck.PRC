if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_ListForListenerCheck]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_ListForListenerCheck]
GO

CREATE Procedure dbo.Restaurant_ListForListenerCheck
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT     r.RID           AS RestaurantID
          ,erbrestaurant.ServerIP           AS NetAddress
          ,erbrestaurant.serverPwd     AS Password
          ,erbrestaurant.ProductID     AS Product_ID
          ,LastTimeContacted.LTC AS LastTimeContacted
FROM       Restaurant r
INNER JOIN ERBRestaurant 
ON         r.RID = ERBRestaurant.RID
INNER JOIN LastTimeContacted
ON		   r.RID = LastTimeContacted.RID
WHERE     (r.RestStateID = 1) 
and        r.Allotment          <> 1
and	r.RID not in (select RID from ListenerVersions)


GO

GRANT EXECUTE ON [Restaurant_ListForListenerCheck] TO ExecuteOnlyRole

GO
