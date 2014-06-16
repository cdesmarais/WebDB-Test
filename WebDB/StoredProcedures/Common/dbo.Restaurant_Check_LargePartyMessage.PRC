if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Check_LargePartyMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Check_LargePartyMessage]
GO

CREATE Procedure dbo.Restaurant_Check_LargePartyMessage
 (
  @RestaurantID int,
  @retval nvarchar(999) output
 )
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 
declare  @LargeParty int
		,@DefaultNoTimesMessage nvarchar(500)

exec DNGetMessageTypeID 'LargeParty',@LargeParty output
set @retVal = (select dbo.fGetRestaurantMessage(@RestaurantID, @LargeParty))

GO

GRANT EXECUTE ON [Restaurant_Check_LargePartyMessage] TO ExecuteOnlyRole

GO
