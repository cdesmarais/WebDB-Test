if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddRestaurantDomain]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddRestaurantDomain]
GO

--
-- Adds a new record to the RestaurantDomain table
-- TT 22481 mmc

CREATE Procedure dbo.AddRestaurantDomain

	@OldRID		int,
	@DomainID	int,
	@NewRID		int,
	@EffectiveDate	datetime
As

IF NOT EXISTS
	(
		SELECT	* 
		FROM	RestaurantDomain
		WHERE	RID = @OldRID
	)
	BEGIN
		-- do the insert
		INSERT INTO RestaurantDomain (RID, DomainID, NewRID, EffectiveDate) VALUES (@OldRID, @DomainID, @NewRID, @EffectiveDate)
	END
GO

GRANT EXECUTE ON [AddRestaurantDomain] TO ExecuteOnlyRole

GO

