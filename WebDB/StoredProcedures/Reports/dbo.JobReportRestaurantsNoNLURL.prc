
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportRestaurantsNoNLURL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportRestaurantsNoNLURL]
GO

CREATE PROCEDURE dbo.JobReportRestaurantsNoNLURL
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
set nocount on 

-- The purpose of this report is to report what restaurants are not yet naturalized for single.aspx and rest_profile.aspx
-- Restaurants without NL URLs that are either Active or Updating Book
--rest_profile
select		 r.RID as rest_profile_rid
			,cast(r.RName as nvarchar(50)) 'Restaurant Name'
from		RestaurantVW r
left join	NLURLVW nl
on			nl.RID		= r.RID
and			nl.NLRuleID	= 8
where		r.RestStateID in (1,13)
and			r.DomainID in (1,70) -- COM, CO.UK
and			nl.RID is null
and			(metroareaid <> 1 or metroareaid is null)

print CHAR(13) 

-- Restaurants without NL URLs that are either Active or Updating Book
--single
select		 r.RID as single_rid
			,cast(r.RName as nvarchar(50)) 'Restaurant Name'
from		RestaurantVW r
left join	NLURLVW nl
on			nl.RID		= r.RID
and			nl.NLRuleID	= 1
where		r.RestStateID in (1,13)
and			r.DomainID in (1,70) -- COM, CO.UK
and			nl.RID is null
and			(metroareaid <> 1 or metroareaid is null)

GO

GRANT EXECUTE ON [JobReportRestaurantsNoNLURL] TO ExecuteOnlyRole
GO
