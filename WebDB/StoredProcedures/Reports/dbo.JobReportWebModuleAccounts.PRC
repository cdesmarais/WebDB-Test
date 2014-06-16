
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportWebModuleAccounts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportWebModuleAccounts]
go



CREATE  PROCEDURE dbo.JobReportWebModuleAccounts 

as

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select 
	r.RID,
	r.[RName] 'RestaurantName',
	m.[MetroAreaName] 'RestaurantMetro',
	rs.[RState] 'AccountStatus',
	r.[CreateDate] 'AccountCreateDate'
from [RestaurantVW] r with (nolock)
inner join [RestaurantState] rs with (nolock)
on r.[RestStateID] = rs.[RestStateID]
inner join [NeighborhoodVW] n with (nolock) 
on r.[LanguageID] = n.[LanguageID]
and r.[NeighborhoodID] = n.[NeighborhoodID]
inner join [MetroAreaVW] m with (nolock)
on n.[LanguageID] = m.[LanguageID]
and n.[MetroAreaID] = m.[MetroAreaID]
where r.[RestaurantType] = 'A'
and r.[Allotment] = 1
--and r.[RestStateID] not in (1,4)  -- Per TT37122, Jim requested to remove this line.



GO

GRANT EXECUTE ON [JobReportWebModuleAccounts] TO ExecuteOnlyRole

GO