if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Check_SpecialDayMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Check_SpecialDayMessage]
GO

CREATE Procedure dbo.Restaurant_Check_SpecialDayMessage
 (
  @RestaurantID int,
  @ResDate datetime,
  @retval nvarchar(999) output
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if exists(Select Message from BlockedDayVW where RID = @RestaurantID and BlockedDate = @ResDate)
BEGIN
	EXEC dbo.DNGetRestaurantMessage @RestaurantID, 1, @retval OUTPUT, @ResDate 
	Declare @RName as nvarchar(100)
	Select @Rname = Rname from RestaurantVW where rid = @RestaurantID
	Set @retval = replace(@retval,'{0}',@Rname)
END
else
BEGIN
	Set @retval = ''
END

GO

GRANT EXECUTE ON [Restaurant_Check_SpecialDayMessage] TO ExecuteOnlyRole

GO
