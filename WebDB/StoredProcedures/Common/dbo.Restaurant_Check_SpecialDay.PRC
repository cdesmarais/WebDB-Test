if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Check_SpecialDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Check_SpecialDay]
GO

CREATE Procedure dbo.Restaurant_Check_SpecialDay

(
@RestaurantID int,
@ResDate datetime,
@retval int  OUTPUT 
)

 AS

Set transaction isolation level read uncommitted

if exists  
	(Select RID from BlockedDay where BlockedDay.RID = @RestaurantID and BlockedDate = @ResDate)
	 Select @retval = 1
Else
	 Select @retval = 0
	 
GO

GRANT EXECUTE ON [Restaurant_Check_SpecialDay] TO ExecuteOnlyRole

GO
