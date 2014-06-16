--$ create proc dbgMakeRestaurants
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dbgMakeRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[dbgMakeRestaurants]
go
create proc dbo.dbgMakeRestaurants
(
	@RIDBegin int, @RIDEnd int, @Allotment bit
)
as
	set nocount on

	declare  @RestName			nvarchar(64)
			,@ReserveCode		nvarchar(64)
			,@AccessPwd			nvarchar(32)
			,@RID				int
			,@TZID				int
			,@DomainID			int
			,@NeighborhoodID	int
			,@LanguageID		int
			,@CountryID			char(2)
			
	set @AccessPwd 		 = 'QATEST'
	set @RID       		 = @RIDBegin

	-- =============================================================================
	-- Begin Transaction
	-- =============================================================================

	begin transaction
	SET IDENTITY_INSERT dbo.Restaurant ON
	ALTER TABLE [dbo].[Restaurant]  DROP  CONSTRAINT [CK_Restaurant_RID] 

	-- =============================================================================
	-- Set up basic data
	-- =============================================================================

	set @NeighborhoodID = 1
	set @DomainID		= 1
	set @LanguageID		= 1
	
	set @TZID = 4
	set @CountryID = 1

--	select	 @TZID		= TZID
--			,@CountryID = CountryID 
--	from		MetroArea			m
--	inner join	Neighborhood		n
--	on			m.MetroAreaID		= n.MetroAreaID
--	where		n.NeighborhoodID	= @NeighborhoodID

	-- =============================================================================
	-- Create Restaurants
	-- =============================================================================

	while ( @RID <= @RIDEnd )
	begin

		if ( not exists(select 1 from Restaurant where RID = @RID) )
		begin

			set @RestName = 'TestRestaurant_' + convert(nvarchar(32), @RID)
			set @ReserveCode = 'RC_' + convert(nvarchar(32), @RID)

			-- ========================================
			-- Add to Restaurant
			-- ========================================
			INSERT INTO Restaurant
			(
				RID,
				DomainID,
				r.RestaurantType,
				r.MinOnlineOptionID,
				r.ParkingID,
				r.SmokingID,
				DressCodeID,
				r.PriceQuartileID,
				r.WOID,
				r.TZID,
				r.neighborhoodid,
				r.MaxOnlineOptionID,
				r.MinTipSizeOptionID,
				r.MaxAdvanceOptionID,
				r.RestStateID,
				DiningStyleID,
				r.Country,
				r.ReserveCode,
				r.HasBanquet,
				r.HasCatering,
				r.HasPrivateParty,
				r.HasGiftCertificate,
				r.Allotment,
				r.MaxLargePartyID,
				r.Ping,
				r.MinCCOptionID,
				r.CCAccountStatusID,
				r.RomsModifiedDTUTC
			)
			VALUES
			(
				@RID,
				@DomainID,		--DomainID,	 
				case WHEN @Allotment = 1 THEN 'A' ELSE 'E' end,
				-- @RestaurantType,--r.RestaurantType,  /*Set the RestaurantType to ERB, Allotment, or Guestbridge */
				1,				--r.MinOnlineOptionID,
				1,				--r.ParkingID,
				2,				--r.SmokingID,
				3,				--DressCodeID,
				2,				--r.PriceQuartileID,
				1,				--r.WOID,
				@TZID,			--r.TZID,
				@NeighborhoodID,--r.neighborhoodid,
				20,				--r.MaxOnlineOptionID,
				1,				--r.MinTipSizeOptionID,
				33,				--r.MaxAdvanceOptionID,
				2,				--r.RestStateID,
				2,				--DiningStyleID,
				@CountryID,		--r.Country,
				@ReserveCode,	--r.ReserveCode,
				0,				--r.HasBanquet,
				0,				--r.HasCatering,
				0,				--r.HasPrivateParty,
				0,				--r.HasGiftCertificate,
				@Allotment,		--r.Allotment,
				20,				--r.MaxLargePartyID,
				0,				--r.Ping
				20,				--r.MinCCOptionID,
				case WHEN @DomainID = 2 THEN 2 /*Opted Out*/ ELSE 1 /*default=No BT Action Taken*/ END,
				case WHEN @DomainID = 2 THEN GETUTCDATE() END 
			)		
			
			-- ========================================
			-- Add to RestaurantLocal
			-- ========================================

			insert into RestaurantLocal
			(
				RID, LanguageID, RName, RSName, Address1, City, State
			)	
			values
			(
				@RID, @LanguageID, @RestName, '', '799 Market Street', 'San Francisco', 'CA'
			)
				
		end
		
		if ( not exists(select 1 from ERBRestaurant where RID = @RID) )
		begin
		
			-- ========================================
			-- Add to ERBRestaurant
			-- ========================================		
		
			insert into ERBRestaurant
			(
				RID
				,ServerIP
				,serverPwd
				,ServerKey
				,ProductID
				,StaticIPAddress
				,ERBVersion
				,ListenerVersion
			)
			values
			(
				@RID
				,'bogus:2368'
				,@AccessPwd
				,'DUMMY'
				,14 -- product type
				,0 -- static IP
				,case WHEN @Allotment = 1 THEN '1.0.0.1000' ELSE null end
				,case WHEN @Allotment = 1 THEN '1.0.0.1000' ELSE null end
			)
		end
				

		set @RID = @RID + 1
	end

	-- =============================================================================
	-- Restore Constraints
	-- =============================================================================

	SET IDENTITY_INSERT dbo.Restaurant OFF
	ALTER TABLE [dbo].[Restaurant]  WITH NOCHECK ADD  CONSTRAINT [CK_Restaurant_RID] CHECK  (([RID] % 3 = 1))

	-- =============================================================================
	-- Commit Transaction
	-- =============================================================================

	commit transaction

GO
