if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheReferrers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheReferrers]
GO

CREATE PROCEDURE [dbo].[DNCacheReferrers]
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select [ReferrerID], [ReferrerName], [IncentiveTypeID], [SuppressAlternative], [PointsOn], [ExcludeFromBillingTypeRule], [ExcludeFromPrimarySourceTypeRule]
from [Referrer]
order by [ReferrerID]
GO

GRANT EXECUTE ON [DNCacheReferrers] TO ExecuteOnlyRole
GO
