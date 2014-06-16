IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoadRestaurantOffer]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[LoadRestaurantOffer]
GO
CREATE PROCEDURE [dbo].[LoadRestaurantOffer] 
	@OfferID INT,
	@OfferTypeID INT,
	@RID INT,
	@OfferName nvarchar(50),
	@StartDate datetime,
	@EndDate datetime,
	@DOWBits varbinary(1),
	@Times00_745 varbinary(4),
	@Times08_1545 varbinary(4),
	@Times16_2345 varbinary(4),
	@DailyMaxInventory int,
	@resocode nvarchar(20),
	@OfferDescription nvarchar(500),
	@MinPartySize int,
	@MaxPartySize int,
	@FinePrint nvarchar(1000),
	@OfferClassID int,
	@ThirdPartyOfferID int,
	@CurrencyTypeID int,
	@OfferPrice smallmoney,
	@NewOfferID INT OUTPUT
AS
BEGIN
	DECLARE @VersionID INT,
			@Message varchar(255)
	BEGIN TRY
		BEGIN TRAN 
			    set @OfferID = isnull((select restaurantofferid from RestaurantOffer where thirdpartyofferid = @ThirdPartyOfferID),0) 
				IF (@OfferID = 0) --Create new offer
				 BEGIN
					--Set version, since it's the first time an offer is being created use Version=1
					SET	@VersionID = 1
					--SET @ThirdPartyOfferID = @RID + 100000 -- In phase 1 there can only be 1 offer per RID
				 
					INSERT	[dbo].[RestaurantOffer]
						(
							[OfferTypeID]
						   ,[OfferStatusID]
						   ,[RID]
						   ,[OfferName]
						   ,[StartDate]
						   ,[EndDate]
						   ,[Days]
						   ,[Times00_745]
						   ,[Times08_1545]
						   ,[Times16_2345]
						   ,[DailyMaxCovers]
						   ,[SeatedCovers]
						   ,[PendingCovers]
						   ,[ResoCode]
						   ,[OfferDescription]
						   ,[MinPartySize]
						   ,[MaxPartySize]
						   ,[ExcludesTaxTip]
						   ,[NoteToDiners]
						   ,[CreatedDtUTC]
						   ,[CreatedBy]
						   ,[UpdatedDtUTC]
						   ,[UpdatedBy]
						   ,[PostedDtUTC]
						   ,[Priority]
						   ,[DisplayOnOTWebsite]
						   ,[DisplayOnRestWebsite]
						   ,[LockOverrideDTUTC]
						   ,[UnlockedBy]
						   ,[OfferVersion]
						   ,[OfferClassID]
						   ,[TTOfferID]
						   ,[ThirdPartyOfferID]
						   ,[CurrencyTypeID]
						   ,[OfferPrice]
						   
						)
					VALUES
						(
							@OfferTypeID--<OfferTypeID, int,>other
						   ,2--<OfferStatusID, int,>1=Active, 2=pending
						   ,@RID--<RID, int,>
						   ,@OfferName
						   ,@StartDate--<StartDate, datetime,>
						   ,@EndDate--<EndDate, datetime,>
						   ,@DOWBits--<Days, varbinary(1),>
						   ,0--<Times00_745, varbinary(4),>
						   ,0--<Times08_1545, varbinary(4),>
						   ,0--<Times16_2345, varbinary(4),>
						   ,@DailyMaxInventory--<DailyMaxCovers, int,>
						   ,0--<SeatedCovers, int,>
						   ,0--<PendingCovers, int,>
						   ,'OT Discounted Meal'--<ResoCode, nvarchar(20),>
						   ,@OfferDescription
						   ,@MinPartySize--<MinPartySize, int,>
						   ,@MaxPartySize--<MaxPartySize, int,>
						   ,0--<ExcludesTaxTip, bit,>
						   ,@FinePrint--<NoteToDiners, nvarchar(80),>
						   ,GETUTCDATE()--<CreatedDtUTC, datetime,>
						   ,SYSTEM_USER--<CreatedBy, nvarchar(100),>
						   ,Null--<UpdatedDtUTC, datetime,>
						   ,Null--<UpdatedBy, nvarchar(100),>
						   ,Null--<PostedDtUTC, datetime,>
						   ,Null--<Priority, int,>
						   ,Null--<DisplayOnOTWebsite, bit,>
						   ,Null--<DisplayOnRestWebsite, bit,>
						   ,Null--<LockOverrideDTUTC, datetime,>
						   ,Null--<UnlockedBy, nvarchar(100),>
						   ,@VersionID--Offer Version,
						   ,@OfferClassID--<OfferClassID, int,>
						   ,Null--<TTOfferID, int,>
						   ,@ThirdPartyOfferID--<ThirdPartyOfferID, int,>
						   ,@CurrencyTypeID
						   ,@OfferPrice
						   
						)
						
						           
					SET	@NewOfferID = SCOPE_IDENTITY()

				--Insert an entry into OfferVersion table if an Insert/Update happened
				--Insert into version table
					INSERT	dbo.OfferVersion
							(
								OfferID,
								VersionID,
								OfferDescription
							)
					VALUES	(
								@NewOfferID,
								@VersionID,
								@OfferDescription
							)
							PRINT 'Created Offer in WebDB for RID:' + CAST(@RID AS VARCHAR)
					
			 END
			 ELSE
			  BEGIN--Phase 1 we will not update the version
					UPDATE	RestaurantOffer
					
					SET		OfferName = @OfferName,
							OfferStatusID=2,
							OfferDescription = @OfferDescription,
							--OfferTypeID = @OfferTypeID,--Do we wanna allow change of OfferType?
							StartDate = @StartDate,
							EndDate = @EndDate,
							[Days] = @DOWBits,
							DailyMaxCovers = @DailyMaxInventory,
							MinPartySize = @MinPartySize,
							MaxPartySize = @MaxPartySize,
							CurrencyTypeID = @CurrencyTypeID,
							ResoCode='OT Discounted Meal',
							OfferPrice = @OfferPrice,
							OfferTypeID = @OfferTypeID,
							NoteToDiners=@FinePrint,
							UpdatedBy = SYSTEM_USER,
							UpdatedDtUTC = GETUTCDATE()
							
					WHERE	RestaurantOfferID = @OfferID
					AND		OfferClassID=@OfferClassID	
					
					IF (@@ROWCOUNT < 1)
						RAISERROR('Invalid OfferID',16,1)
				PRINT 'Updated Offer in WebDB for RID:' + CAST(@RID AS VARCHAR)
				SET	@NewOfferID=@OfferID
			  END
			COMMIT TRAN
			
			
	END TRY
	BEGIN CATCH
		SET	@Message = 'Error:Inserting/Updating Offer in WebDB [' + ISNULL(ERROR_MESSAGE(),'') +']'
		if XACT_STATE() <> 0 
			ROLLBACK TRAN
		RAISERROR (@Message, 16, 1)
	END CATCH
		
END

GO

GRANT EXECUTE ON LoadRestaurantOffer TO ExecuteOnlyRole
GO

