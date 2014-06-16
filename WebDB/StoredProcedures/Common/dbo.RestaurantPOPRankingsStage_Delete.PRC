if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantPOPRankingsStage_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantPOPRankingsStage_Delete]
GO

create procedure [dbo].[RestaurantPOPRankingsStage_Delete]
as
  delete from [dbo].[RestaurantPOPRankingsStage]
go

GRANT EXECUTE ON [RestaurantPOPRankingsStage_Delete] TO ExecuteOnlyRole
GO
GRANT EXECUTE ON [RestaurantPOPRankingsStage_Delete] TO DTR_User
GO
  