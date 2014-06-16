if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_Restaurant_GetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_Restaurant_GetByID]
GO


CREATE PROCEDURE dbo.XML_Restaurant_GetByID
(
@RestaurantID int
)

 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select er.RID as Restaurant_ID
,er.ServerIP as Server_IP
,LTC.LTC as last_time_contacted
,getDate() as Server_Time
,CASE 
         WHEN r.RestStateID = 1 AND isReachable = 1 THEN 'Reserve Now'
         WHEN r.RestStateID = 1 AND isReachable = 0 THEN 'Back Soon'
         ELSE rs.Rstate
      END as Restaurant_State_ID,
ProductID as Product_ID 
from erbrestaurant er
inner Join Restaurant r on er.rid = r.rid
inner Join RestaurantState rs on r.RestStateID = rs.RestStateID
inner join LastTimeContacted LTC on er.rid = LTC.rid
where er.rid = @RestaurantID

GO

GRANT EXECUTE ON [XML_Restaurant_GetByID] TO ExecuteOnlyRole

GO
