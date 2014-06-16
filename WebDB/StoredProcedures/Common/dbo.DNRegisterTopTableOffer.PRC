--Create Stored Proc.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRegisterTopTableOffer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRegisterTopTableOffer]
GO

CREATE PROCEDURE [dbo].[DNRegisterTopTableOffer]
@TTOfferID				INT,
@OfferName				NVARCHAR(50),
@OfferDescription		NVARCHAR(300),
@RID					INT
AS

--Remove Spaces
SET	@OfferDescription = LTRIM(RTRIM(@OfferDescription))

--Validation
IF (@TTOfferID IS NULL)
	RAISERROR('Error: @TTOfferID can not be null.',16,1)
IF (@OfferName IS NULL OR LEN(@OfferName) < 1)
	RAISERROR('Error: OfferName can not be Null or blank',16,1)
IF (@OfferDescription IS NULL OR LEN(@OfferDescription) < 1)
	RAISERROR('Error: OfferDescription can not be Null or blank',16,1)


DECLARE		@Message			NVARCHAR(3000)
DECLARE		@OfferClassID		INT = 2 --Reserved ID for TopTable Offers
DECLARE		@OTOfferID			INT
DECLARE		@VersionID			INT
DECLARE		@UpdatePerformed	BIT = 0


--Handle topTable offers, these are Self Maintaining offers
--Self Maintaining Offers create a new entry the first time OR update an existing 
--entry in Restuarant Offers if there is a change in offer description
SELECT		@OTOfferID=RestaurantOfferID,
			@VersionID=OfferVersion
FROM		RestaurantOffer
WHERE		TTOfferID=@TTOfferID
AND			OfferClassID=@OfferClassID
AND			LTRIM(RTRIM(OfferDescription)) = @OfferDescription

--If the Offer Exists and there is no change to the offer then Return
IF (@@ROWCOUNT > 0)
 BEGIN 
	SELECT	@OTOfferID AS OfferID,
			@VersionID AS OfferVersionID
	RETURN 1
 END
ELSE--otherwise start a transaction and do the Insert/Update into main Offers table and an insert into OfferVersion table
--From this point onwards we will use _TTUnique column instead of TTOfferID column to access RestaurantOffer table
-- we are doing this so that locking works properly; _TTUnique column has a Unique Constraint/index on it which helps
-- the sql server in taking locks on only one row at a time thereby keeping rest of the records unlocked.
-- A uniqueness constarint can not be implemented on TTOfferID because it has NULL values for Offers that are not TopTable Offers
--_TTUnique column is a computed column and will have -ve values for non TopTable Offers

 BEGIN
	BEGIN TRY
		BEGIN TRAN
			--Lock the record if it exists so that no other transaction can update it and capture the Version
			--Concurrency Use Case: If one transaction comes to update TTOfferID=1 and another one comes almost at the same
			--time to update same offer TTOfferID=1; then the following lock will make the 2nd transaction wait until 1st has finished.
			SELECT	@VersionID = OfferVersion, 
					@OTOfferID = RestaurantOfferID
			FROM	RestaurantOffer WITH (ROWLOCK UPDLOCK) -- See Comment above for locking details
			WHERE	_TTUnique = @TTOfferID  -- See Comment above for locking details

			IF (@@ROWCOUNT > 0)
			 BEGIN
				--Update the main offers table
				UPDATE	dbo.RestaurantOffer
				SET		OfferDescription = @OfferDescription,
						OfferVersion = @VersionID + 1
				WHERE	_TTUnique = @TTOfferID   -- See Comment above for locking details
				AND		OfferDescription <> @OfferDescription
				
				--This would prevent a concurrency scenario where 2 transaction simulaneously
				--pass for changed description and try to do the update, the 2nd one will have @RowCount=0
				IF (@@ROWCOUNT > 0)
					BEGIN
						SET @UpdatePerformed = 1
						SET @VersionID += 1 -- an update was performed above with the incremented version
					 END
			 END
			ELSE -- TTOffer doesn't exist
			 BEGIN
				BEGIN TRY
					--Set version
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
							   
							)
					VALUES
							(
								7--<OfferTypeID, int,>other
							   ,1--<OfferStatusID, int,>Active
							   ,@RID--<RID, int,>Since RID isn't relevant for TT offers we only store the RID the first time; it's ignored during updates
							   ,@OfferName
							   ,'1/1/1900'--<StartDate, datetime,>
							   ,'12/31/9999'--<EndDate, datetime,>
							   ,0x00--<Days, varbinary(1),>
							   ,0x00000000--<Times00_745, varbinary(4),>
							   ,0x00000000--<Times08_1545, varbinary(4),>
							   ,0x00000000--<Times16_2345, varbinary(4),>
							   ,0--<DailyMaxCovers, int,>
							   ,0--<SeatedCovers, int,>
							   ,0--<PendingCovers, int,>
							   ,''--<ResoCode, nvarchar(20),>
							   ,@OfferDescription
							   ,0--<MinPartySize, int,>
							   ,0--<MaxPartySize, int,>
							   ,0--<ExcludesTaxTip, bit,>
							   ,null--<NoteToDiners, nvarchar(80),>
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
							   ,@OfferClassID
							   ,@TTOfferID
							)
		           
					IF (@@ROWCOUNT > 0)
						SET @UpdatePerformed = 1
		           
					SET	@OTOfferID = SCOPE_IDENTITY()
					
				END TRY
				BEGIN CATCH
					DECLARE	@Error INT =@@ERROR
					--This block of code is to deal with a concurrency scenario where 2 transaction pass for new offer
					--and try to insert into the RestuarntOffers table.
					--If the insert failed that means the record exists, update the record if needed
					IF (@Error=2627)--2627 is the Primary/Unique Key Constraint violation
					 BEGIN
						--Lock the record if it exists so that no other transaction can update it and capture the Version
						SELECT	@VersionID = OfferVersion, 
								@OTOfferID = RestaurantOfferID
						FROM	RestaurantOffer WITH (ROWLOCK UPDLOCK) -- See Comment above Line#45 for locking details
						WHERE	_TTUnique = @TTOfferID-- See Comment above Line#45 for locking details
					 
						--Update the main offers table if there is a change
						UPDATE	dbo.RestaurantOffer
						SET		OfferDescription = @OfferDescription,
								OfferVersion = @VersionID + 1
						WHERE	_TTUnique = @TTOfferID-- See Comment above Line#45 for locking details
						AND		OfferDescription <> @OfferDescription
					
						--This would prevent a concurrency scenario where 2 transaction simulaneously
						--pass for changed description and try to do the update, the 2nd one will have @RowCount=0
						IF (@@ROWCOUNT > 0)
						 BEGIN
							SET @UpdatePerformed = 1
							SET @VersionID += 1 -- an update was performed above with the incremented version
						 END
					 END
					
					--Raise any other error
					If (@@ERROR <> 0 OR @Error <> 2627)
					 BEGIN
						SET @Message = 'Error found in DNRegisterTopTableOffer:' + ISNULL(ERROR_MESSAGE(),'') + ']'
						RAISERROR(@Message,16,1)
					 END
					
				END CATCH
			END 

		--Insert an entry into OfferVersion table if an Insert/Update happened
		--Insert into version table
		IF (@UpdatePerformed = 1)
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
		
		SELECT	@OTOfferID AS OfferID,
				@VersionID AS OfferVersionID
		
		RETURN 1
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SET	@Message = 'Error:Inserting/Updating TT Offer [' + ISNULL(ERROR_MESSAGE(),'') +']'
		RAISERROR (@Message, 16, 1)
	
		SELECT	NULL AS OfferID,
				Null AS OfferVersionID
		
		RETURN 0
	END CATCH
 END

GO


GRANT EXECUTE ON [DNRegisterTopTableOffer] TO ExecuteOnlyRole

GO
