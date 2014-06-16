--Create a table type for DayLevel Schedule for OT Offers
IF NOT EXISTS (SELECT * FROM sys.types WHERE name='OfferDayLevelSchedule' AND is_table_type=1)
	CREATE TYPE dbo.OfferDayLevelSchedule AS TABLE 
	( 
		 DOW				INT				NOT NULL
		,MaxInventory		INT				NOT NULL
		,SlotBits1			VARBINARY(4)	NOT NULL
		,SlotBits2			VARBINARY(4)	NOT NULL
		,SlotBits3			VARBINARY(4)	NOT NULL
		,MinPartySize		INT				NOT NULL
		,MaxPartySize		INT				NOT NULL
	);
GO

GRANT EXECUTE ON TYPE::dbo.OfferDayLevelSchedule TO ExecuteOnlyRole
GO

--Create a table type for SlotLevel Schedule for OT Offers
IF NOT EXISTS (SELECT * FROM sys.types WHERE name='OfferSlotLevelSchedule' AND is_table_type=1)
	CREATE TYPE dbo.OfferSlotLevelSchedule AS TABLE 
	( 
		 DOW				INT				NOT NULL
		,SlotTime			TIME			NOT NULL
		,MaxInventory		INT				NOT NULL
		,MinPartySize		INT				NOT NULL
		,MaxPartySize		INT				NOT NULL
	);
GO

GRANT EXECUTE ON TYPE::dbo.OfferSlotLevelSchedule TO ExecuteOnlyRole
GO

--Create a table type for OfferTypeAttributeValue
IF NOT EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'OfferTypeAttributeValue')
	CREATE TYPE [dbo].[OfferTypeAttributeValue] AS TABLE
	(
		[RestaurantOfferID] [int] NOT NULL,
		[OfferTypeAttributeKeyID] [int] NOT NULL,
		[ValueText] [nvarchar](200) NULL,
		[ValueInt] [int] NULL
	)
GO

GRANT EXECUTE ON TYPE::dbo.OfferTypeAttributeValue TO ExecuteOnlyRole
GO

--Stored proc
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ReservationOffer_ManageSchedule_OT]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[ReservationOffer_ManageSchedule_OT]
GO


/*
This proc creates/modifies/deletes schedule of an Offer
*/
CREATE PROCEDURE [dbo].[ReservationOffer_ManageSchedule_OT]
	@RID				INT,
	@OTOfferID			INT,
	@OfferTypeID		INT,
	@OfferClassID		INT,
	@OfferName			NVARCHAR(70),
	@OfferDescription	NVARCHAR(500),
	@StartDate			DATE,
	@EndDate			DATE,
	@CurrencyTypeID		INT,
	@OfferPrice			SMALLMONEY,
	@FinePrint			NVARCHAR(1000),
	@DOWBits			VARBINARY(1),
	@DayLevelSchedule	OfferDayLevelSchedule READONLY,
	@SlotLevelSchedule	OfferSlotLevelSchedule READONLY,
	@ActionTypeID		INT,	--1 Create/Modify Offer
							--2 Remove Offer
	@OffTypeAttrs		OfferTypeAttributeValue READONLY,
	@ExcludesTax		bit,
	@ExcludesService	bit,
	@MinPartySize		int,
	@MaxPartySize		int,
	@DisplayOnOTWebsite bit = 0,
	@User				NVARCHAR(100) = 'SysUser' 

AS

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE		@Message				NVARCHAR(3000)
DECLARE		@VersionID				INT
DECLARE		@UpdateOfferVesion		BIT = 0
DECLARE		@RowCount				INT = 0
DECLARE		@CurrOfferDescription	NVARCHAR(500)
DECLARE		@CurrOfferPrice			SMALLMONEY
DECLARE 	@ResoCode 				NVARCHAR(20)
DECLARE 	@CurrOfferName 			NVARCHAR(70)
DECLARE 	@CurrResoCode 			NVARCHAR(100)
DECLARE		@ActiveOfferCount		INT

--This proc assumes that a RID assigned to an OfferID cannot be changed 
BEGIN TRY
	IF (@User = 'SysUser')
		Select @User = SYSTEM_USER
	--Validation
	IF (@RID IS NULL)
		RAISERROR('Error: @RID can not be null.',16,1)
			
	IF (@OTOfferID IS NULL)
		RAISERROR('Error: @OTOfferID can not be null.',16,1)

	IF (@ActionTypeID =1)
	 BEGIN
		IF (@OfferName IS NULL OR LEN(@OfferName) < 1)
			RAISERROR('Error: OfferName can not be Null or blank',16,1)

		IF (@OfferDescription IS NULL OR DATALENGTH(@OfferDescription) < 1)
			RAISERROR('Error: OfferDescription can not be Null or blank',16,1)

		IF (@StartDate IS NULL OR @EndDate IS NULL)
			RAISERROR('Error: @StartDate OR @EndDate can not be null.',16,1)

		--Check EndDate
		IF (@EndDate = '1/1/1900')
			RAISERROR('Invalid @EndDate, 1/1/1900 is a reserved value for EndDate!',16,1)
			
		 --Validate DOW
		IF ( (SELECT COUNT(1) FROM @DayLevelSchedule) <> 7)
			RAISERROR('@DayLevelSchedule expects exactly 7 records', 16, 1)
				
		 
		IF EXISTS( SELECT 1 FROM @DayLevelSchedule WHERE DOW NOT BETWEEN 1 and 7)
			RAISERROR('Invalid value for DOW in @DayLevelSchedule', 16, 1)

		--Validate values in the table-valued parameter @DayLevelSchedule
		--Expects to have zero values for MaxInventory and Min and Max PartySize for an inactive day.
		--Expects to have greater than zero values for MaxInventory and Min and Max PartySize for active days.
		--Expects MaxPartySize is always greater than or equal to MinPartySize
		IF EXISTS	(
						SELECT	1 
						FROM	@DayLevelSchedule 
						WHERE	
								(
									POWER(2, (7-DOW)) & @DOWBits = 0 AND --InactiveDOW
									(
										MaxInventory	<> 0 OR --Any inactive days should have maxinventory=0
										MinPartySize	<> 0 OR --Any inactive days should have MinPartySize=0
										MaxPartySize	<> 0 OR --Any inactive days should have MaxPartySize=0
										SlotBits1		<> 0 OR --Any inactive days should have SlotBits=0x00000000
										SlotBits2		<> 0 OR
										SlotBits3		<> 0
									)
									
								)
						
						OR		(
									POWER(2, (7-DOW)) & @DOWBits <> 0 AND --Active DOW
									(
										MaxInventory < 1 OR
										MinPartySize < 1 OR -- Must be a non-zero positive value
										MaxPartySize < 1 OR	-- Must be a non-zero positive value
										(
											SlotBits1 = 0 AND -- All active days should have at least one non-zero SlotBits
											SlotBits2 = 0 AND
											SlotBits3 = 0
										)
									)
								)
						
						OR		MinPartySize > MaxPartySize -- Min & Max Party Size Test
						
					)
			RAISERROR('Invalid value passed for at least one of the record in @DayLevelSchedule', 16, 1)

		--Validate SlotLevel Schedule
		--Make sure a SlotLevel Schedule exists for each active Time Slot
		IF EXISTS
		(
			SELECT a.DOW,b.SlotTime 
			FROM @DayLevelSchedule a
			CROSS APPLY 
			(
				SELECT * FROM slot 
				WHERE slotid>0 
				and (
						CAST(mask1 AS BIGINT)& a.slotbits1 <>0 or 
						CAST(mask2 AS BIGINT)& a.slotbits2 <>0 or 
						CAST(mask3 AS BIGINT)& a.slotbits3 <>0
					)
			) b
			FULL OUTER JOIN	@SlotLevelSchedule c
			ON				a.DOW=c.DOW
			AND				b.SlotTime=c.SlotTime
			WHERE			c.SlotTime IS NULL
			OR				b.SlotTime IS NULL
		)
			RAISERROR('Missing/Extra SlotLevel Schedule for some time slots!', 16, 1)
	
	----End validation
	 
		--Question for Ed: Should we make Version change sensitive to OfferTypeID now instead of offerDescription?
		--Get existing offerdescription to see if there is a change that would require a version change
		SELECT	@VersionID = OfferVersion, 
				@OTOfferID = RestaurantOfferID,
				@CurrOfferDescription = OfferDescription,
				@CurrOfferPrice = OfferPrice,
				@CurrOfferName 	= OfferName,
				@CurrResoCode  = ResoCode
		FROM	RestaurantOffer 
		WHERE	RestaurantOfferID=@OTOfferID 
		AND		OfferClassID=@OfferClassID

		SET		@RowCount = @@ROWCOUNT
		
		SET 	@CurrOfferName = RTRIM(LTRIM(@CurrOfferName))
		SET 	@CurrResoCode = RTRIM(LTRIM(@CurrResoCode))
		
		--Get the ResoCode for the Offer using the BusinessRuleView		
		SELECT @ResoCode = orc.ResoCode   
		FROM OfferResoCodesRuleAVW orc  
		JOIN RestaurantLocal r
		on orc.LanguageID = r.LanguageID
		WHERE orc.OfferTypeID = @OfferTypeID  
		AND   orc.OfferClassID = @OfferClassID  
		AND r.RID = @RID

		IF (@@ROWCOUNT <> 1 OR @ResoCode IS NULL)
			RAISERROR('Invalid ResoCode',16,1)

		BEGIN TRY
			BEGIN TRAN
				IF (@RowCount > 0 AND @OTOfferID<>0)
				 BEGIN -- Existing Offer
					IF NOT EXISTS	(	
										SELECT	1 
										FROM	RestaurantOffer WITH (READUNCOMMITTED) 
										WHERE	RestaurantOfferID=@OTOfferID 
										AND		OfferClassID=@OfferClassID
										AND		RID=@RID
									)
					 BEGIN
						RAISERROR ('Invalid @RID and @OTOfferID combination!',16,1)
					 END
				 
					--Change Version only if any of the info transmitted to the ERB/Console has changed
					--For PromotedOffers it's OfferName or ResoCode 
					
					IF (ISNULL(@CurrOfferName, '') <> ISNULL(@OfferName, '') OR ISNULL(@CurrResoCode, '') <> ISNULL(@ResoCode, ''))
					 BEGIN
						SET @UpdateOfferVesion = 1
						SET @VersionID += 1 -- increment version
					 END

					UPDATE	RestaurantOffer
					SET		OfferName = @OfferName,
							OfferDescription = @OfferDescription,
							OfferTypeID = @OfferTypeID,
							StartDate = @StartDate,
							EndDate = @EndDate,
							[Days] = @DOWBits,
							OfferVersion = @VersionID,
							CurrencyTypeID = @CurrencyTypeID,
							OfferPrice = @OfferPrice,
							NoteToDiners = @FinePrint,
							UpdatedBy = @User,
							UpdatedDtUTC = GETUTCDATE(),
							OfferStatusID = 1, -- Set to Active (dbo.RestuarantOfferStatus)
							ResoCode = @ResoCode,
							ExcludesService = @ExcludesService,
							ExcludesTax = @ExcludesTax,
							MinPartySize = @MinPartySize,
							MaxPartySize = @MaxPartySize,
							DisplayOnOTWebsite = @DisplayOnOTWebsite
					WHERE	RestaurantOfferID=@OTOfferID 
					AND		OfferClassID=@OfferClassID
					AND		RID = @RID
					
					--update offer type attributes
					BEGIN
						Update OfferTypeAttributeValue 
							set OfferTypeAttributeValue.ValueText = offTypeAttr.ValueText,
							OfferTypeAttributeValue.ValueInt = offTypeAttr.ValueInt
							FROM OfferTypeAttributeValue tblOfferType
							inner join @OffTypeAttrs offTypeAttr on 
							tblOfferType.RestaurantOfferID = offTypeAttr.RestaurantOfferID
							and tblOfferType.OfferTypeAttributeKeyID = offTypeAttr.OfferTypeAttributeKeyID
					END
							 

					--During the update of an Offer; if a RID is blacklisted then it should stay blacklisted
					--Do not make any changes here to ValueLookupIDList for LookupID = 74
					
					--**Update the DayLevelSchedule**
					UPDATE		o
					SET			MaxInventory =	ISNULL(d.MaxInventory,0),
								SlotBits1	=   d.SlotBits1,
								SlotBits2	=	d.SlotBits2,
								SlotBits3	=	d.SlotBits3,
								MinPartySize =  d.MinPartySize,
								MaxPartySize =	d.MaxPartySize
					FROM		dbo.OfferDayLevelSchedule o
					LEFT JOIN	@DayLevelSchedule d
					ON			o.DOW = d.DOW
					WHERE		o.RestaurantOfferID = @OTOfferID
					AND			o.[Date] = '1/1/1900'    -- ONLY UPDATE Default schedule records, not the custom schedule
					AND			o.DOW BETWEEN 1 AND 7

					IF (@@ROWCOUNT <> 7)-- There should always be 7 default records
						RAISERROR('Missing/Extra Day in the DayLevelSchedule during Modify!',16,1)
					
				 END
				ELSE IF (@OTOfferID = 0)-- New Offer
				 BEGIN
					SELECT @ActiveOfferCount = COUNT(1) FROM RestaurantOffer ro WITH (READUNCOMMITTED) 
					INNER JOIN Restaurant rvw
					ON ro.RID = rvw.RID
					INNER JOIN TimezoneVW tvw
					ON tvw.TZID = rvw.TZID
						WHERE ro.RID = @RID 
						AND ro.OfferClassID = 4 --promoted offer
						AND ro.OfferStatusID = 1 --active offer
						--check if end date is in future compared to local date of restaurant
						AND CAST(tvw.currentLocalTime AS DATE) <= ro.EndDate 
						
					IF (@ActiveOfferCount >= 10)
						RAISERROR('@RID cannot have greater than 10 active offers',16,1)

					--Set version, since it's the first time an offer is being created use Version=1
					SET	@VersionID = 1
					
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
						   ,ExcludesTax
						   ,ExcludesService
						   
						)
					VALUES
						(
							@OfferTypeID--<OfferTypeID, int,>
						   ,1--<OfferStatusID, int,>Active
						   ,@RID--<RID, int,>
						   ,@OfferName
						   ,@StartDate--<StartDate, datetime,>
						   ,@EndDate--<EndDate, datetime,>
						   ,@DOWBits--<Days, varbinary(1),>
						   ,0--<Times00_745, varbinary(4),>
						   ,0--<Times08_1545, varbinary(4),>
						   ,0--<Times16_2345, varbinary(4),>
						   ,0--<DailyMaxCovers, int,>
						   ,0--<SeatedCovers, int,>
						   ,0--<PendingCovers, int,>
						   ,@ResoCode --<ResoCode, nvarchar(20),>
						   ,@OfferDescription
						   ,@MinPartySize
						   ,@MaxPartySize
						   ,0--<ExcludesTaxTip, bit,>
						   ,@FinePrint--<NoteToDiners, nvarchar(80),>
						   ,GETUTCDATE()--<CreatedDtUTC, datetime,>
						   ,@User
						   ,Null--<UpdatedDtUTC, datetime,>
						   ,Null--<UpdatedBy, nvarchar(100),>
						   ,Null--<PostedDtUTC, datetime,>
						   ,Null--<Priority, int,>
						   ,@DisplayOnOTWebsite
						   ,Null--<DisplayOnRestWebsite, bit,>
						   ,Null--<LockOverrideDTUTC, datetime,>
						   ,Null--<UnlockedBy, nvarchar(100),>
						   ,@VersionID--Offer Version,
						   ,@OfferClassID--<OfferClassID, int,>
						   ,Null--<TTOfferID, int,>
						   ,Null--<ThirdPartyOfferID, int,>
						   ,@CurrencyTypeID--<CurrencyTypeID, int,>
						   ,@OfferPrice--<OfferPrice, int,>
						   ,@ExcludesTax
						   ,@ExcludesService
						)
						
					IF (@@ROWCOUNT > 0)
						SET @UpdateOfferVesion = 1
						           
					SET	@OTOfferID = SCOPE_IDENTITY()
									
					--insert into offer type attribute
					BEGIN
						Insert OfferTypeAttributeValue
							([RestaurantOfferID]
							,[OfferTypeAttributeKeyID]
							,[ValueText]
							,[ValueInt])
							SELECT 
						     @OTOfferID
							,[OfferTypeAttributeKeyID]
							,[ValueText]
							,[ValueInt]
							FROM @OffTypeAttrs 
					END

					
					--During the creation of an Offer; if a RID is blacklisted then it should stay blacklisted
					-- TT 49451, Do not make any changes here to ValueLookupIDList for LookupID = 74   
					
					--**Insert the DayLevelSchedule**
					INSERT		OfferDayLevelSchedule 
								(
								RestaurantOfferID, DOW, [DATE], 
								MaxInventory, MinPartySize, MaxPartySize, 
								SlotBits1, SlotBits2, SlotBits3
								)
					SELECT		@OTOfferID, DOW, '1/1/1900',
								MaxInventory, MinPartySize, MaxPartySize,
								SlotBits1, SlotBits2, SlotBits3
					FROM		@DayLevelSchedule
					WHERE		DOW BETWEEN 1 AND 7
					
					IF (@@ROWCOUNT <> 7)-- There should always be 7 default records
						RAISERROR('Missing/Extra Day in the DayLevelSchedule during Create!',16,1)
					
				 END
				 
				 ELSE
				  BEGIN
					RAISERROR('Invalid action, can''t Insert or Update Offer!',16,1)
				  END
				
				
				--*******************************************************************************************************************
				--**********For now we are Disabling the SlotLevelOverrides for Promoted Offers.
				--***BEGIN Commenting out SlotLevelSchedule

				----**SlotLevelSchedule**--Begin
				
				----Update existing ones
				--UPDATE		s
				--SET			MaxInventory = sl.MaxInventory,
				--			MinPartySize = sl.MinPartySize,
				--			MaxPartySize = sl.MaxPartySize
				--FROM		dbo.OfferSlotLevelSchedule s
				--INNER JOIN	@SlotLevelSchedule sl
				--ON			s.DOW = sl.DOW
				--AND			s.SlotTime = sl.SlotTime
				--WHERE		s.RestaurantOfferID = @OTOfferID
				--AND			s.DOW BETWEEN 1 AND 7
				--AND			s.[Date] = '1/1/1900'-- ONLY UPDATE Default schedule records, not Custom Schedule
				--AND			s.SlotTime BETWEEN '00:00' AND '23:45'
				
				----Add new ones if any
				--INSERT		dbo.OfferSlotLevelSchedule
				--SELECT		@OTOfferID AS RestaurantOfferID
				--			,sl.DOW
				--			,'1/1/1900' AS [Date]
				--			,sl.SlotTime
				--			,sl.MaxInventory
				--			,sl.MinPartySize
				--			,sl.MaxPartySize
				--FROM		@SlotLevelSchedule sl
				--LEFT JOIN	dbo.OfferSlotLevelSchedule s
				--ON			@OTOfferID = s.RestaurantOfferID
				--AND			sl.DOW = s.DOW
				--AND			'1/1/1900' = s.[DATE]-- ONLY UPDATE Default schedule records, not Custom Schedule
				--AND			sl.SlotTime = s.SlotTime
				--WHERE		sl.DOW BETWEEN 1 AND 7
				--AND			sl.SlotTime BETWEEN '00:00' AND '23:45'
				--AND			s.RestaurantOfferID IS NULL -- Pick new records
				
				----Delete the ones not in the new set
				--DELETE		s
				--FROM		dbo.OfferSlotLevelSchedule s
				--LEFT JOIN	@SlotLevelSchedule sl
				--ON			s.DOW = sl.DOW
				--AND			s.SlotTime = sl.SlotTime
				--WHERE		s.RestaurantOfferID = @OTOfferID
				--AND			s.DOW BETWEEN 1 AND 7
				--AND			s.[Date] = '1/1/1900'-- ONLY UPDATE Default schedule records, not Custom Schedule
				--AND			s.SlotTime BETWEEN '00:00' AND '23:45'
				--AND			sl.SlotTime IS NULL
		
				----**SlotLevelSchedule**--End
				--***END Commenting out SlotLevelSchedule
				--*******************************************************************************************************************

				--Insert an entry into OfferVersion table if an Insert/Update happened
				--Insert into version table
				IF (@UpdateOfferVesion = 1)
				 BEGIN
					INSERT	dbo.OfferVersion
							(
								OfferID,
								VersionID,
								OfferDescription,
								OfferName,
								ResoCode
							)
					VALUES	(
								@OTOfferID,
								@VersionID,
								@OfferDescription,
								@OfferName,
								@ResoCode
							)
				 END
				 
					
			COMMIT TRAN
			
			SELECT	@OTOfferID AS RetVal
			RETURN @OTOfferID
			
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SET	@Message = ISNULL(ERROR_MESSAGE(),'')
			RAISERROR (@Message, 16, 1)

			SELECT	0 AS RetVal
			RETURN 0
		END CATCH
	END
	ELSE IF (@ActionTypeID=2) --Remove Offer
	BEGIN
		UPDATE	RestaurantOffer
		SET		OfferStatusID = 3, -- Set to expired (dbo.RestuarantOfferStatus)
				DisplayOnOTWebsite = 0,
				UpdatedBy = @User
		WHERE	RestaurantOfferID=@OTOfferID
		AND		OfferClassID = @OfferClassID
		AND		RID = @RID
		
		IF (@@ROWCOUNT < 1)
		 BEGIN
			SET	@Message = 'Error:Suspending OTOffer. @OTOfferID doesn''t exist! [' + ISNULL(ERROR_MESSAGE(),'') +']'
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
END TRY
BEGIN CATCH
	SET	@Message = 'Error:Inserting/Updating OTOffer [' + ISNULL(ERROR_MESSAGE(),'') +']'
	RAISERROR (@Message, 16, 1)

	SELECT	0 AS RetVal
	RETURN 0
END CATCH

GO

GRANT EXECUTE ON [dbo].[ReservationOffer_ManageSchedule_OT] TO ExecuteOnlyRole

GO
