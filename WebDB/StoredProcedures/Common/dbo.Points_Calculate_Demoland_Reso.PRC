if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Points_Calculate_Demoland_Reso]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Points_Calculate_Demoland_Reso]
GO


CREATE  procedure dbo.Points_Calculate_Demoland_Reso
  @ResID			int,
  @metroAreaID      int,
  @points			int OUTPUT 
AS
    SET NOCOUNT ON
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
	
    DECLARE  @callerID int, @customerID int, @count int, @enabled int
   
    IF (@metroAreaID <> 1)
      RETURN

	SET @enabled = 0

    select @enabled = ValueInt from ValueLookup
		where LType = 'WEBSERVER' 
		and LKey = 'WHITELIST_POINTS_ENABLED'
	
	if (@enabled <> 1)
	   return
	  
    SELECT  
    @customerID = Coalesce(Reservation.CustID, 0),
	@callerID = Coalesce(Reservation.CallerID, 0)
	FROM      dbo.Reservation 
	WHERE Reservation.ResID = @ResID
	  
   IF (@callerID = 0)
   BEGIN
	 SELECT @count = count(*)
	 FROM dbo.UserPointsList
	 WHERE customerID = @customerID
   END 
   ELSE
   BEGIN
     SELECT @count = count(*)
	 FROM dbo.UserPointsList
	 WHERE callerID = @callerID   
   END
   
   IF (@count = 0)
   BEGIN
     SET @points = 0  
   END
GO


GRANT EXECUTE ON [Points_Calculate_Demoland_Reso] TO ExecuteOnlyRole
GO
