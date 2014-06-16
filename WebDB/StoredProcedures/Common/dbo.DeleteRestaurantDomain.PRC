if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DeleteRestaurantDomain]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DeleteRestaurantDomain]
GO

--
-- Deletes a record from the RestaurantDomain table
-- TT 22481 mmc

CREATE Procedure dbo.DeleteRestaurantDomain

	@RID		int
As

IF EXISTS
	(
		SELECT	* 
		FROM	RestaurantDomain
		WHERE	RID = @RID
	)
	BEGIN
		DELETE	RestaurantDomain
		WHERE	RID = @RID
	END
GO

GRANT EXECUTE ON [DeleteRestaurantDomain] TO ExecuteOnlyRole

GO

