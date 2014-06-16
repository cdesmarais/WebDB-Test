IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ReservationOffer_ManageSchedule]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[ReservationOffer_ManageSchedule]
GO


/*
This proc creates/modifies/deletes schedule of an Offer
*/
CREATE PROCEDURE dbo.ReservationOffer_ManageSchedule
	@RID				INT,
	@ThirdPartyOfferID	INT,
	@OfferTypeID		INT,
	@OfferClassID		INT,
	@OfferName			NVARCHAR(50),
	@OfferDescription	NVARCHAR(500),
	@StartDate			DATE,
	@EndDate			DATE,
	@CurrencyTypeID		INT,
	@OfferPrice			SMALLMONEY,
	@FinePrint			NVARCHAR(1000),
	@ActionTypeID		INT	--1 Create/Modify Offer
							--2 Remove Offer
AS

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE		@Message				NVARCHAR(3000)
DECLARE		@VersionID				INT
DECLARE		@UpdateOfferVesion		BIT = 0
DECLARE		@OTOfferID				INT
DECLARE		@RowCount				INT = 0
DECLARE		@CurrOfferDescription	NVARCHAR(500)
DECLARE		@CurrOfferPrice			SMALLMONEY
DECLARE 	@ResoCode 				NVARCHAR(20)

--This proc assumes that a RID assigned to an OfferID cannot be changed thus making

--Validation
IF (@RID IS NULL)
	RAISERROR('Error: @RID can not be null.',16,1)
IF (@ThirdPartyOfferID IS NULL)
	RAISERROR('Error: @ThirdPartyOfferID can not be null.',16,1)

IF (@ActionTypeID =1)
 BEGIN
	IF (@OfferName IS NULL OR LEN(@OfferName) < 1)
		RAISERROR('Error: OfferName can not be Null or blank',16,1)
	IF (@OfferDescription IS NULL OR LEN(@OfferDescription) < 1)
		RAISERROR('Error: OfferDescription can not be Null or blank',16,1)
	IF (@StartDate IS NULL OR @EndDate IS NULL)
		RAISERROR('Error: @StartDate OR @EndDate can not be null.',16,1)

 
	SELECT	@VersionID = OfferVersion, 
			@OTOfferID = RestaurantOfferID,
			@CurrOfferDescription = OfferDescription,
			@CurrOfferPrice = OfferPrice
	FROM	RestaurantOffer 
	WHERE	_ThirdPartyNonNull=@ThirdPartyOfferID 
	AND		OfferClassID=@OfferClassID

	SET		@RowCount = @@ROWCOUNT
	
	SET		@OfferDescription = RTRIM(LTRIM(@OfferDescription))
	SET		@CurrOfferDescription = RTRIM(LTRIM(@CurrOfferDescription))
	

	BEGIN TRY
		BEGIN TRAN
			IF @RowCount > 0
			 BEGIN -- Existing Offer
				IF NOT EXISTS	(	
									SELECT	1 
									FROM	RestaurantOffer WITH (READUNCOMMITTED) 
									WHERE	_ThirdPartyNonNull=@ThirdPartyOfferID 
									AND		OfferClassID=@OfferClassID
									AND		RID=@RID
								)
				 BEGIN
					RAISERROR ('Invalid @RID and @ThirdPartyOfferID combination!',16,1)
				 END
			 
				--Version 1 will not allow Version change
				----Change Version only if some billing related information has changed
				----for now it's just the OfferDescription and OfferPrice
				--IF (ISNULL(@CurrOfferDescription,'') <> ISNULL(@OfferDescription,'') OR ISNULL(@CurrOfferPrice,0) <> ISNULL(@OfferPrice,0))
				-- BEGIN
				--	SET @UpdateOfferVesion = 1
				--	SET @VersionID += 1 -- incremented version
				-- END

				UPDATE	RestaurantOffer
				
				SET		OfferName = @OfferName,
						OfferDescription = @OfferDescription,
						--OfferTypeID = @OfferTypeID,--Do we wanna allow change of OfferType?
						StartDate = @StartDate,
						EndDate = @EndDate,
						--OfferVersion = @VersionID,--Change not allowed in Version 1 of API
						CurrencyTypeID = @CurrencyTypeID,
						OfferPrice = @OfferPrice,
						NoteToDiners = @FinePrint,
						UpdatedBy = SYSTEM_USER,
						UpdatedDtUTC = GETUTCDATE(),
						OfferStatusID = 1 -- Set to Active (dbo.RestuarantOfferStatus)
						
						
				WHERE	_ThirdPartyNonNull=@ThirdPartyOfferID 
				AND		OfferClassID=@OfferClassID	

				--During the update of an Offer; if a RID is blacklisted then it should stay blacklisted
				--Do not make any changes here to ValueLookupIDList for LookupID = 74
				
			 END
			ELSE -- New Offer
			 BEGIN
				--Set version, since it's the first time an offer is being created use Version=1
				SET	@VersionID = 1
				
				--Savored isn't allowed to have more than one offer for a RID; perform the check for that
				IF EXISTS	(	
								SELECT		1
								FROM		[RestaurantOffer] WITH (READUNCOMMITTED)
								WHERE		RID = @RID
								AND			OfferClassID = @OfferClassID
							)
					BEGIN
						RAISERROR ('An Offer already exists for this RID; only one offer per RID is allowed!',16,1)
					END
					
				
				
				SELECT @ResoCode = ResoCode FROM OfferResoCode WHERE  OfferClassID=@OfferClassID	
			 
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
					   ,CurrencyTypeID
					   ,OfferPrice
					   
					)
				VALUES
					(
						@OfferTypeID--<OfferTypeID, int,>
					   ,1--<OfferStatusID, int,>Active
					   ,@RID--<RID, int,>
					   ,@OfferName
					   ,@StartDate--<StartDate, datetime,>
					   ,@EndDate--<EndDate, datetime,>
					   ,0--<Days, varbinary(1),>
					   ,0--<Times00_745, varbinary(4),>
					   ,0--<Times08_1545, varbinary(4),>
					   ,0--<Times16_2345, varbinary(4),>
					   ,0--<DailyMaxCovers, int,>
					   ,0--<SeatedCovers, int,>
					   ,0--<PendingCovers, int,>
					   ,@ResoCode --<ResoCode, nvarchar(20),>
					   ,@OfferDescription
					   ,0--<MinPartySize, int,>
					   ,0--<MaxPartySize, int,>
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
					   ,@CurrencyTypeID--<CurrencyTypeID, int,>
					   ,@OfferPrice--<OfferPrice, int,>
					)
					
				IF (@@ROWCOUNT > 0)
					SET @UpdateOfferVesion = 1
					           
				SET	@OTOfferID = SCOPE_IDENTITY()
				
				--During the creation of an Offer; if a RID is blacklisted then it should stay blacklisted
				-- TT 49451, Do not make any changes here to ValueLookupIDList for LookupID = 74   
			 END

			--Insert an entry into OfferVersion table if an Insert/Update happened
			--Insert into version table
			IF (@UpdateOfferVesion = 1)
			 BEGIN
				INSERT	dbo.OfferVersion
						(
							OfferID,
							VersionID,
							OfferDescription
						)
				VALUES	(
							@OTOfferID,
							@VersionID,
							@OfferDescription
						)
			 END
			 
				
		COMMIT TRAN
		
		SELECT	@OTOfferID AS RetVal
		RETURN @OTOfferID
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SET	@Message = 'Error:Inserting/Updating ThirdParty Offer [' + ISNULL(ERROR_MESSAGE(),'') +']'
		RAISERROR (@Message, 16, 1)

		SELECT	0 AS RetVal
		RETURN 0
	END CATCH
END
ELSE IF (@ActionTypeID=2) --Remove Offer
BEGIN
	SELECT	@OTOfferID = RestaurantOfferID
	FROM	RestaurantOffer 
	WHERE	_ThirdPartyNonNull=@ThirdPartyOfferID 
	AND		OfferClassID=@OfferClassID

	UPDATE	RestaurantOffer
	SET		OfferStatusID = 2, -- Set to suuspended (dbo.RestuarantOfferStatus)
			EndDate = '1/1/1900' -- Set to expired
	WHERE	_ThirdPartyNonNull = @ThirdPartyOfferID
	AND		OfferClassID = @OfferClassID
	
	IF (@@ROWCOUNT < 1)
	 BEGIN
		SET	@Message = 'Error:Suspending ThirdParty Offer. @ThirdPartyOfferID doesn''t exist! [' + ISNULL(ERROR_MESSAGE(),'') +']'
			RAISERROR (@Message, 16, 1)
		SELECT	0 AS RetVal
		RETURN 0
	 END
	ELSE
	 BEGIN
		SELECT	@OTOfferID AS RetVal
		RETURN @OTOfferID
	 END

END


GO



GRANT EXECUTE ON [dbo].[ReservationOffer_ManageSchedule] TO ExecuteOnlyRole

GO
