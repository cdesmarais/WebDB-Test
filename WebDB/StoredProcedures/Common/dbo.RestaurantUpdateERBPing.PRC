if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantUpdateERBPing]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantUpdateERBPing]
GO


CREATE PROCEDURE dbo.RestaurantUpdateERBPing
 (
  @RID int,
  @QueryString nvarchar(255),
  @RemoteAddress nvarchar(50)
 )
As

SET NOCOUNT ON

insert into ErbPingLog (RID,QueryString,RemoteAddress)
Select @RID as RID
,@QueryString as QueryString
,@RemoteAddress as RemoteAddress
from ERBRestaurant er
where er.RID = @RID and er.Track = 1


GO

GRANT EXECUTE ON [RestaurantUpdateERBPing] TO ExecuteOnlyRole

GO
