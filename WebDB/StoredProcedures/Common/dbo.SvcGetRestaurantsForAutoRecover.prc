if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcGetRestaurantsForAutoRecover]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcGetRestaurantsForAutoRecover]
GO

--*********************************************************
--** Retrieves a list of restaurants that will want to 
--** check for connectivity, based on the restaurantstate
--*********************************************************
-- Also pass in the RID list as defined by the Aggregator, this contains the in-memory state of the 
-- aggregator, it ensures that every in-memory alert is accounted for..
CREATE PROCEDURE dbo.SvcGetRestaurantsForAutoRecover
(
	@stateList varchar(5000) --[EV: List of Int IDs]
)
As
	set transaction isolation level read uncommitted
	SET NOCOUNT ON
		
	SELECT	 r.RID					RestaurantID
			,r.RName				RestaurantName
			,r.RestStateID			RestStateID
			, (case when (charindex(':',serverIP) > 0)
				then substring(serverIP, 1, charindex(':',er.serverIP)-1) 
				else ''
				end)				IPAddress
			, (case when (charindex(':',serverIP) > 0)
				then cast(substring(serverIP, charindex(':',er.serverIP)+1, 10) as int)
				else -1
				end)				Port
			,er.ServerIP			NetAddress
			,er.serverPwd			Password
			,r.MinOnlineOptionID	MinPartySize
			,r.MaxOnlineOptionID	MaxPartySize
			,'' AS R
			,r.Allotment as Allotment
			,'1/1/1900'				before
			,'1/1/1900'				exact
			,'1/1/1900'				after
			,0						IsActive
			,0						Erb_err
			,''						ListenerVersion
			,'1/1/1900'				StartTime
			,'1/1/1900'				StopTime
			,0						Socket_Status
			,0						Track

	from		RestaurantVW r

	inner join	ERBRestaurant er
	on			r.RID = er.RID
		
	where		CHARINDEX(',' + CAST(r.RestStateID AS varchar) + ',', ',' + @stateList + ',') > 0
	and			r.Allotment <> 1  -- ** Never include Allotment restaurants in FRN
	and         r.IsReachable = 1

GO



GRANT EXECUTE ON [SvcGetRestaurantsForAutoRecover] TO ExecuteOnlyRole

GO
