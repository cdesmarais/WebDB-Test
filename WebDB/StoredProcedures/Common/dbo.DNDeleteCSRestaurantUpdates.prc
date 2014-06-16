if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNDeleteCSRestaurantUpdates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNDeleteCSRestaurantUpdates]
GO



-- Delete all records earlier than the ID that was sent in..
CREATE PROCEDURE dbo.DNDeleteCSRestaurantUpdates
(
	@CSRestUpdateIDHWM int
)
  
As

-- delete from csrestupdates table..
--delete from csrestupdates where CSUpdateID <= @CSRestUpdateIDHWM   //REPLACED BY Batching 

DECLARE @x INT
SET @x = 1

SET ROWCOUNT 1000

WHILE @x > 0
BEGIN
 BEGIN TRAN
	delete from csrestupdates where CSUpdateID <= @CSRestUpdateIDHWM
 SET @x = @@rowcount
 COMMIT TRAN
END 

SET ROWCOUNT 0

GO
GRANT EXECUTE ON [DNDeleteCSRestaurantUpdates] TO ExecuteOnlyRole

GO
