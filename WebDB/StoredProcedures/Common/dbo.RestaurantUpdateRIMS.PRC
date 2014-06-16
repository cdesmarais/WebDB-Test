GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantUpdateRIMS]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantUpdateRIMS]
GO





CREATE  Procedure dbo.RestaurantUpdateRIMS
 (
  @RID int,
  @Version nvarchar(50),
  @MessageID int,
  @Package nvarchar(50),
  @Message nvarchar(50)
 )
As

Insert into RestaurantRIMSLog
(RID,Version,MessageID,Package,Message)
VALUES
(@RID,@Version,@MessageID,@Package,@Message)


GO


GRANT EXECUTE ON [RestaurantUpdateRIMS] TO ExecuteOnlyRole

GO
