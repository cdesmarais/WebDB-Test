if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetRestandProvidersByMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetRestandProvidersByMetro]
GO

CREATE Procedure dbo.Admin_GetRestandProvidersByMetro

(
@Metro_ID int
 )

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select Distinct 
			r.RName as [Name]
			,r.RID as Restaurant_ID
			,Provider.ProviderName as Providers 
			,r.RSName as [RSName]
from		RestaurantVW r
Inner Join	Neighborhood n 
On			r.neighborhoodid = n.neighborhoodid
Inner Join	MetroArea 
On			n.metroareaid = MetroArea.metroareaid
left join	Content 
on			r.RID = Content.RID
left Join	Provider 
On			Provider.ProviderID = Content.ProviderID
where		MetroArea.metroareaid = @Metro_ID
Order by	[RSName], [Name]

GO


GRANT EXECUTE ON [Admin_GetRestandProvidersByMetro] TO ExecuteOnlyRole

GO
