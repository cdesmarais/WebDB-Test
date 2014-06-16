if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetRestConnectionStatusForMetroByDomainID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetRestConnectionStatusForMetroByDomainID]
GO

CREATE PROCEDURE dbo.Admin_GetRestConnectionStatusForMetroByDomainID
(
	@DomainID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
/*
	This Stored procedure get Restaurant connection status for metro by domainID. This is used by PJR job "CharmConnectionStatusReport"
	for preparing the connection status report. 
	
	Content owned by India team,
    please notify asaxena@opentable.com if changing.
*/
SELECT 
			 ma.MetroAreaName
			,ma.metroareaid
			,SUM(Case when (r.IsReachable = 1 AND r.RestStateID = 1) then 1 Else 0 End) AS 'Reserve Now'
			,SUM(Case when (r.IsReachable = 0 AND r.RestStateID = 1) then 1 Else 0 End) AS 'Back Soon'
			,SUM(Case when (r.RestStateID =2) then 1 Else 0 End) AS 'Awaiting Install'
			,SUM(Case when (r.RestStateID =5) then 1 Else 0 End) + SUM(Case when (r.RestStateID =6) then 1 Else 0 End) AS 'Closed Temporarily'			
			,SUM(Case when (r.RestStateID =7) then 1 Else 0 End) AS 'Temporarily Inactive'
			,SUM(Case when (r.RestStateID =10) then 1 Else 0 End) AS 'Client Grace Period'
			,SUM(Case when (r.RestStateID =12) then 1 Else 0 End) AS 'Waiting for Connectivity'
			,SUM(Case when (r.RestStateID in (8,9)) then 1 Else 0 End) AS 'Initiating Uninstall'
			,SUM(Case when (r.RestStateID =11) then 1 Else 0 End) AS 'Decline Online With Connectivity'
			,SUM(Case when (r.RestStateID =15) then 1 Else 0 End) AS 'Decline Online Without Connectivity'
			,SUM(Case when (r.RestStateID =14) then 1 Else 0 End) AS 'No Connectivity'
			,SUM(Case when (r.RestStateID =13) then 1 Else 0 End) AS 'Update Book'
			,SUM(Case when (r.RestStateID =16) then 1 Else 0 End) AS 'False Reserve Now'
			
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
AND			d.[DomainID] =  @DomainID
GROUP BY	 ma.MetroAreaName
			,ma.metroareaid
ORDER BY	 ma.MetroAreaName ASC
option		(keepfixed plan)


GO

GRANT EXECUTE ON [Admin_GetRestConnectionStatusForMetroByDomainID] TO ExecuteOnlyRole

GO
