if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobInsertROMSRestaurantGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobInsertROMSRestaurantGroup]
GO

CREATE Procedure dbo.JobInsertROMSRestaurantGroup
as
/******************************************************************************
Procedure select data from a RomsVW and populates tables RestaurantGroup and 
RestaurantToGroup in WEBDB
This sets up the group relationships between GID and RID
Check if insert actaully pulls any records, rollback truncate statement if no 
records are inserted or the procedure error out.
******************************************************************************/
SET NOCOUNT ON

declare @ErrorMsg as nvarchar(1000)

SET TRAN ISOLATION LEVEL READ UNCOMMITTED

Begin Transaction

	delete from restaurantgroup
	if @@ERROR <> 0
	goto error
	
	Set @ErrorMsg = 'Failed to truncate RestaurantGroupTbl'


	Insert into	restaurantGroup
	Select distinct GID, GroupName from ROMSRestaurantGroup
	if @@ERROR <> 0
	goto error
	
	
	Set @ErrorMsg = 'Failed to Insert RestaurantGroupTbl'
	if @@ERROR <> 0
	goto error


	delete from restaurantTogroup
	if @@ERROR <> 0
	goto error
	
	Set @ErrorMsg = 'Failed to truncate RestaurantToGroupTbl'

		
	Insert into	restaurantToGroup
	Select distinct RID, GID from ROMSRestaurantGroup
	if @@ERROR <> 0
	goto error

	Set @ErrorMsg = 'Failed to Insert RestaurantToGroupTbl'
	if @@ERROR <> 0
	goto error



	--If all is well...
	Commit Transaction

	return(0)

error:
   	ROLLBACK TRAN
	exec DNErrorAdd 88, 'JobInsertROMSRestaurantGroup', @ErrorMsg, 1	
	raisError ('throw error',15, 1)

GO

GRANT EXECUTE ON [JobInsertROMSRestaurantGroup] TO ExecuteOnlyRole

GO

