if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConValidateRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConValidateRID]
GO


CREATE  procedure dbo.OTConValidateRID

  @RestaurantID			int
as

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select		COUNT(*)
from		Restaurant
where		RID = @RestaurantID
and			RestaurantType = 'A'

GO

GRANT EXECUTE ON [OTConValidateRID] TO ConsoleExecuteRole

GO
