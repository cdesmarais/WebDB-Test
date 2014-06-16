if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogGetFailedSearchCountTotal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogGetFailedSearchCountTotal]
GO

CREATE PROCEDURE dbo.DNLogGetFailedSearchCountTotal 
(
	@nRestaurantID int
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

if (@nRestaurantID = 0) -- return all log counts
	select * from FailedSearchTotals
else
	select * from FailedSearchTotals where RID = @nRestaurantID
	
GO

GRANT EXECUTE ON [DNLogGetFailedSearchCountTotal] TO ExecuteOnlyRole

GO
