if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Weekly_RestaurantRequest_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Weekly_RestaurantRequest_Update]
GO

CREATE PROCEDURE dbo.Report_Weekly_RestaurantRequest_Update

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

Update	RestaurantRequest 
set		Sent = 1 
where	Sent != 1

GO

GRANT EXECUTE ON [Report_Weekly_RestaurantRequest_Update] TO ExecuteOnlyRole

GO
