if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantLogERBUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantLogERBUpdate]
GO


CREATE PROCEDURE dbo.RestaurantLogERBUpdate
 (
  @RID int,
  @QueryString nvarchar(255),
  @RemoteAddress nvarchar(50)
 )
As

SET NOCOUNT ON

insert into ErbUpdateLog (RID,QueryString,RemoteAddress)
Select @RID as RID
,@QueryString as QueryString
,@RemoteAddress as RemoteAddress
from ERBRestaurant
where ERBRestaurant.RID = @RID 
and Track = 1

GO

GRANT EXECUTE ON [RestaurantLogERBUpdate] TO ExecuteOnlyRole

GO
