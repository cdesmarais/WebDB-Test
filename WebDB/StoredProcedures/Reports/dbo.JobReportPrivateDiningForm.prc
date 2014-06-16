if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportPrivateDiningForm]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportPrivateDiningForm]
GO

CREATE PROCEDURE dbo.JobReportPrivateDiningForm
	@CurrentDate DATETIME = NULL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
set nocount on 

-- Ensure the current date is correct (uses the server date, not UTC)
SET @CurrentDate = ISNULL(@CurrentDate,GETDATE())

-- schedule to run every Monday morning
declare	@StartDate	datetime
declare	@EndDate	datetime

SET @StartDate =	DATEADD(dd, -8, DATEDIFF(dd, 0, @CurrentDate)) -- midnight a week ago
SET @EndDate =		DATEADD(dd, -1, DATEDIFF(dd, 0, @CurrentDate)) -- midnight "yesterday"

SELECT	pd.rid
		,r.RName as RestaurantName
		,pd.Name
		,pd.Email
		,pd.Phone
		,pd.RequestDate
		,case when pd.FlexibleDate = 1 then 'Yes' else 'No' end as FlexibleDate
		,case when pd.CC = 1 then 'Yes' else 'No' end as CC
		,pd.EventType
		,pd.PartySize
		,pd.Details
		,r.MetroAreaID
		,r.MetroAreaName
		,r.MacroID
		,r.MacroName
		,r.NeighborHoodID
		,r.NbhoodName
		,r.PFoodType
		,r.PriceQuartile
		,case when pd.RestSite = 1 then 'Restaurant' else 'OpenTable' end as [Source]
		,pd.FormDateTS
		,pd.IsAnonymous
		
FROM	PrivateDiningRequests pd (nolock)
INNER JOIN RestaurantDetailVW r (nolock)
ON		pd.rid = r.RID

WHERE	pd.FormDateTS between @StartDate and @EndDate
		and pd.Robot = 0

GO
GRANT EXECUTE ON [JobReportPrivateDiningForm] TO ExecuteOnlyRole

GO
