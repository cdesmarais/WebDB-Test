if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantGetCentralParkingList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantGetCentralParkingList]
GO

CREATE Procedure dbo.DNCacheRestaurantGetCentralParkingList
AS

Select rp.Rid,ParkingURl, [Enabled] 
from RestaurantCentralParking rp
inner join Restaurant r 
	on r.RID = rp.RID
where [Enabled] = 1 
and RestStateID <> 4

go

GRANT EXECUTE ON dbo.DNCacheRestaurantGetCentralParkingList TO ExecuteOnlyRole

GO

GRANT EXECUTE ON dbo.DNCacheRestaurantGetCentralParkingList TO WebUserUS

GO



