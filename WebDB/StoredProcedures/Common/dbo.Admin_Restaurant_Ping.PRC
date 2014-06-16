if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_Ping]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_Ping]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_Ping
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 
			 ma.MetroAreaName,
			 ma.metroareaid
			,SUM(Case when (r.IsReachable = 1 AND r.RestStateID = 1) then 1 Else 0 End) AS Uptime
			,SUM(Case when (r.IsReachable = 0 AND r.RestStateID = 1) then 1 Else 0 End) AS DownTime
			,SUM(Case when (r.RestStateID =2) then 1 Else 0 End) AS AwaitingInstall
			,SUM(Case when (r.RestStateID =5) then 1 Else 0 End) AS ClosedTemporarily
			,SUM(Case when (r.RestStateID =6) then 1 Else 0 End) AS Seasonal
			,SUM(Case when (r.RestStateID =7) then 1 Else 0 End) AS TemporarilyInactive
			,SUM(Case when (r.RestStateID =10) then 1 Else 0 End) AS ClientGracePeriod
			,SUM(Case when (r.RestStateID =12) then 1 Else 0 End) AS WaitingforConnectivity
			,SUM(Case when (r.RestStateID in (8,9)) then 1 Else 0 End) AS InitiatingUninstall
			,SUM(Case when (r.RestStateID =11) then 1 Else 0 End) AS DeclineOnline
			,SUM(Case when (r.RestStateID =13) then 1 Else 0 End) AS UpdatingBook
			,SUM(Case when (r.RestStateID =14) then 1 Else 0 End) AS NoConnectivity
			,SUM(Case when (r.RestStateID =15) then 1 Else 0 End) AS DeclineOnlineNoConnectivity
			,SUM(Case when (r.RestStateID =16) then 1 Else 0 End) AS FalseReserveNow
			
FROM		 RestaurantAVW r
INNER JOIN	 Neighborhood n 
ON			 r.neighborhoodid = n.neighborhoodid
INNER JOIN	[Domain] d
ON			r.[DomainID] = d.[DomainID]
AND			r.[LanguageID] = d.PrimaryLanguageID
INNER JOIN	 MetroAreaAVW ma
ON			 ma.metroareaid = n.metroareaid
and			 ma.LanguageID = r.[LanguageID]
and			 ma.[SupportedDomainID] = r.[DomainID]
inner join dbo.DBUser db     
on   ma.SupportedDomainID = isnull(db.DomainID, ma.SupportedDomainID)    
and db.dbuser = user   

WHERE		(ma.metroareaid not in (60,61,67))
AND			r.RestStateID !=4
GROUP BY	 ma.MetroAreaName
			,ma.metroareaid
ORDER BY	 ma.MetroAreaName ASC
option		(keepfixed plan)


GO

GRANT EXECUTE ON [Admin_Restaurant_Ping] TO ExecuteOnlyRole

GO
