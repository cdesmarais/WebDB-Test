if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_PingDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_PingDetails]
GO


CREATE PROCEDURE dbo.Admin_Restaurant_PingDetails
(
  @MetroID nvarchar(10)
)
 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted
if @MetroID = 0
BEGIN
	SELECT     getdate()
	          ,r.RName as Name
	          ,lt.LTC as Last_Time_Contacted
	          ,r.state
	          ,ma.MetroAreaName as Name
	          ,r.RestStateID as Restaurant_State_ID
	          ,r.Allotment
	          ,er.ServerIP as Server_IP
	          ,r.RID as Restaurant_ID
			  ,CASE 
				 WHEN r.RestStateID = 1 AND isReachable = 1 THEN 'Reserve Now'
				 WHEN r.RestStateID = 1 AND isReachable = 0 THEN 'Back Soon'
				 ELSE RState.RState
			  END as Restaurant_status
	          ,r.RSName
	FROM		RestaurantVW r
	INNER JOIN	ERBRestaurant er
	ON			r.RID   = er.RID
	INNER JOIN	Neighborhood n
	ON			r.NeighborhoodID = n.NeighborhoodID
	INNER JOIN	[Domain] d
	ON			r.[DomainID] = d.[DomainID]
	AND			r.[LanguageID] = d.PrimaryLanguageID
	INNER JOIN	MetroAreaAVW ma
	ON			ma.MetroAreaID = n.MetroAreaID
	and			ma.LanguageID = r.LanguageID		
	INNER JOIN	LastTimeContacted lt
	ON			r.RID = lt.RID
	INNER JOIN	Restaurantstate RState
	ON			r.RestStateID   = RState.RestStateID
	
	WHERE		ma.MetroAreaID not in (1,60,61,67)
	AND			r.RestStateID not in (4)
	ORDER BY	r.state
				,ma.MetroAreaName
				,r.RSName ASC
				,r.RName ASC
	option (KEEPFIXED PLAN)
END
else
BEGIN
	SELECT     getdate()
				,r.RName as Name
				,lt.LTC as Last_Time_Contacted
				,r.state
				,ma.MetroAreaName as Name
				,r.RestStateID as Restaurant_State_ID
				,r.Allotment
				,er.ServerIP as Server_IP
				,r.RID as Restaurant_ID
				,CASE 
					 WHEN r.RestStateID = 1 AND isReachable = 1 THEN 'Reserve Now'
					 WHEN r.RestStateID = 1 AND isReachable = 0 THEN 'Back Soon'
					 ELSE RState.RState
				  END as Restaurant_status
				,r.RSName
	FROM		RestaurantVW r
	INNER JOIN	ERBRestaurant er
	ON			r.RID   = er.RID
	INNER JOIN	Neighborhood n
	ON			r.NeighborhoodID = n.NeighborhoodID
	INNER JOIN	[Domain] d
	ON			r.[DomainID] = d.[DomainID]
	AND			r.[LanguageID] = d.PrimaryLanguageID
	INNER JOIN	MetroAreaAVW ma
	ON			ma.MetroAreaID = n.MetroAreaID
	and			ma.LanguageID = r.LanguageID		
	INNER JOIN	LastTimeContacted lt
	ON			r.RID = lt.RID
	INNER JOIN	Restaurantstate RState
	ON			r.RestStateID   = RState.RestStateID
	
	WHERE		(LEN(@MetroID) = 0 
	OR			CHARINDEX(',' + CAST(ma.MetroAreaID AS nvarchar(10)) + ',', ',' + @MetroID + ',') > 0) 
	AND			r.RestStateID not in (4)
	ORDER BY	r.state
				,ma.MetroAreaName
				,r.RSName ASC
				,r.RName ASC
	option (KEEPFIXED PLAN)
END

GO


GRANT EXECUTE ON [Admin_Restaurant_PingDetails] TO ExecuteOnlyRole

GO
