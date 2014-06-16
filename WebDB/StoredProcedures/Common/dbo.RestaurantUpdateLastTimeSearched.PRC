if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantUpdateLastTimeSearched]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantUpdateLastTimeSearched]
GO


CREATE Procedure dbo.RestaurantUpdateLastTimeSearched
 (
  @RestaurantID int,
  @Restaurants nvarchar(4000),
  @Neighborhoods nvarchar(999),
  @MacroNeighborhoods nvarchar(999)
 )
As
SET NOCOUNT ON
--SET TRAN ISOLATION LEVEL SERIALIZABLE
GO



GRANT EXECUTE ON [RestaurantUpdateLastTimeSearched] TO ExecuteOnlyRole

GO
