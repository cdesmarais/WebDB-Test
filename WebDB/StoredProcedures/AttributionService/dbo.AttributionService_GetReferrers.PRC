if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AttributionService_GetReferrers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AttributionService_GetReferrers]
GO

create procedure dbo.AttributionService_GetReferrers
as
set nocount on
set transaction isolation level read uncommitted

SELECT		r.ReferrerID
FROM		Referrer r

go

grant execute on [AttributionService_GetReferrers] to ExecuteOnlyRole

GO