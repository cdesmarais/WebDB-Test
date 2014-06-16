if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_TopList_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_TopList_Delete]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_TopList_Delete
(
  @MetroID int
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION
--**************************
--** Delete Top10 based on the Active DB User (RestaurantVW)
--**************************

Delete from RestaurantTopList 
where RID in (
	select		r.RID 
	from		RestaurantVW r
	inner join	Neighborhood n 
	on			r.neighborhoodid = n.neighborhoodid 
	inner join	MetroArea 
	on			n.metroareaid = MetroArea.metroareaid 
	where		MetroArea.metroareaid = @MetroID
) 
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
ROLLBACK TRANSACTION
Return(0)

GO

GRANT EXECUTE ON [Admin_Restaurant_TopList_Delete] TO ExecuteOnlyRole

GO
