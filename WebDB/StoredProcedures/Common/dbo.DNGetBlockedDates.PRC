if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetBlockedDates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetBlockedDates]
GO

CREATE PROCEDURE dbo.DNGetBlockedDates

AS


declare @dBlock datetime
declare @dToday datetime

set @dToday = convert(nvarchar,getdate(),1)
select distinct RID as RestaurantID, BlockedDate from blockedday where convert(nvarchar,BlockedDate,1) >= @dToday order by RID, BlockedDate
GO


GRANT EXECUTE ON [DNGetBlockedDates] TO ExecuteOnlyRole

GO
