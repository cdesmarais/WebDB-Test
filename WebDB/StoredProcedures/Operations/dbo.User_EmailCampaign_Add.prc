IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[User_EmailCampaign_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[User_EmailCampaign_Add]
GO

CREATE Procedure [dbo].[User_EmailCampaign_Add]
 (  
  @Email nvarchar(255),    
  @PartnerID int,  
  @MetroAreaID int,   
  @EmailCampaignID INT,
  @Spotlight bit = NULL,
  @Insider bit = NULL,
  @DinersChoice bit = NULL,
  @NewHot bit = NULL,
  @RestaurantWeek bit = NULL,
  @Promotional bit = NULL,
  @Product bit = NULL,
  @Rule_AddAnon bit = 0,
  @Rule_SubscribeCallers bit = 0,
  @Rule_ActivateUsers bit= 0,
  @Rule_UpdateMetro bit = 0
 )
 /* The purpose of this proc is to create new users or opt users into email based on special email campaigns.  The paramaters passed in as follows.
  @Email The email address to be opted in,    
  @PartnerID The PartnerID associated the campaign
  @MetroAreaID The metroareaid of the customer.  This is mandatory in order to opt in new customers, but optional if both @Rule_AddAnon and @Rule_UpdateMetro are false
  @EmailCampaignID an identifier for the campaign
  @Spotlight, @Insider, @DinersChoice, @NewHot, @RestaurantWeek, @Promotional, @Product The email optin settings to set.  0=opt out, 1=opt in, NULL=leave unchanged.  Careful using 0.
  @Rule_AddAnon If 1, then we will create new anonymous users for emails not already in our sytsem.  Otherwise these emails will be skipped.
  @Rule_SubscribeCallers If 1, then we update admin caller records.  Otherwise we skip callers.  We never optin concierge.
  @Rule_ActivateUsers If 1, then we activate inactive customers/callers.  Note, we never activate callers flagged as deactivated for fraud.
  @Rule_UpdateMetro If 1 then we update the primary dining city of the user.  Otherwise we leave it alone.
 */
As
SET NOCOUNT ON
DECLARE @CustID INT
DECLARE @CallerID INT
DECLARE @GPID NUMERIC (24,0)
DECLARE @CallerStatusID INT
DECLARE	@Err_NUM INT
        ,@Err_Severity INT
        ,@Err_State INT
        ,@Err_Msg NVARCHAR(1024)
--Find an existing customer/caller
SELECT @CustID=CustID FROM Customer WHERE email = @email and CallerID IS NULL
IF @CustID IS NOT NULL
BEGIN
	SELECT @GPID = _GlobalPersonID FROM GlobalPerson WHERE CustID = @CustID
END
ELSE
BEGIN
	SELECT @CallerID=CallerID, @CallerStatusID=CallerStatusID FROM Caller WHERE loginname = @email
	SELECT @GPID = _GlobalPersonID FROM GlobalPerson WHERE CallerID = @CallerID
END

-- Check if user is inactive and rule is set to not activate users
IF EXISTS(Select CustID from Customer where CustID=@CustID and active = 0) AND @Rule_ActivateUsers = 0
BEGIN
	INSERT INTO EmailCampaignCustomers (EmailCampaignID, GlobalPersonID, EmailCampaignActionID) SELECT @EmailCampaignID, @GPID, 1
	RETURN(0)
END
	
IF @CallerStatusID = 4 OR (@CallerStatusID IN (2,3) AND @Rule_ActivateUsers=0)
BEGIN
	INSERT INTO EmailCampaignCustomers (EmailCampaignID, GlobalPersonID, EmailCampaignActionID) SELECT @EmailCampaignID, @GPID, 1
	RETURN(0)
END	

-- Check if user is a caller and update callers rule is false
IF @CallerID is not null AND @Rule_SubscribeCallers=0
BEGIN
	INSERT INTO EmailCampaignCustomers (EmailCampaignID, GlobalPersonID, EmailCampaignActionID) SELECT @EmailCampaignID, @GPID, 5
	RETURN(0)
END

BEGIN TRANSACTION MyTransaction
	BEGIN TRY
		--Subscribe Callers (depending on flags)  We only subscribe admins and only if @Rule_SubscribeCallers is true
		IF @CallerID IS NOT NULL
		BEGIN
			IF (SELECT PositionID FROM Caller WHERE CallerID=@CallerID)=3 AND  @Rule_SubscribeCallers=1 AND (@CallerStatusID=1 OR (@Rule_ActivateUsers=1 AND (@CallerStatusID IN (2,3))))
			BEGIN
				--set caller to active
				IF (SELECT CallerStatusID FROM Caller WHERE CallerID=@CallerID)=2
					UPDATE Caller SET CallerStatusID = 1 WHERE CallerID=@CallerID
				--Update metro if necessary and enabled
				IF @Rule_UpdateMetro=1
					UPDATE Caller SET MetroAreaID=@MetroAreaID WHERE MetroAreaID<>@MetroAreaID AND CallerID=@CallerID
				--Check is UserOptIn record exists for this caller		
				IF EXISTS(SELECT CallerID FROM UserOptIn WHERE CallerID = @CallerID)
					--update opt-in bits in DB that are 0 where passed in params are 1 (leave others alone)	
					UPDATE UserOptIn SET 
						Spotlight = ISNULL(@Spotlight, Spotlight), 
						Insider = IsNull(@Insider, Insider),
						DinersChoice = IsNull(@DinersChoice, DinersChoice),
						NewHot = IsNull(@NewHot, NewHot),
						RestaurantWeek = IsNull(@RestaurantWeek, RestaurantWeek),
						Promotional = IsNull(@Promotional, Promotional),
						Product = IsNull(@Product, Product),
						UpdatedDtUTC = getutcdate()
					WHERE	CallerID = @CallerID
					AND ((IsNull(@SpotLight, SpotLight) <> SpotLight)
						  OR (IsNull(@Insider, Insider) <> Insider)
						  OR (IsNull(@DinersChoice, DinersChoice) <> DinersChoice)
						  OR (IsNull(@NewHot, NewHot) <> NewHot)
						  OR (IsNull(@RestaurantWeek, RestaurantWeek) <> RestaurantWeek)
						  OR (IsNull(@Promotional, Promotional) <> Promotional)
						  OR (IsNull(@Product, Product) <> Product)
						)
				ELSE	
					INSERT INTO UserOptIn (CallerID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID)
						VALUES(@CallerID,isnull(@Insider,0),isnull(@DinersChoice,0),isnull(@NewHot,0),isnull(@RestaurantWeek,0),isnull(@Promotional,0),isnull(@Spotlight,0),isnull(@Product,0),@MetroAreaID)	
				IF @@ROWCOUNT=0
					INSERT INTO EmailCampaignCustomers (EmailCampaignID, GlobalPersonID, EmailCampaignActionID) SELECT @EmailCampaignID, @GPID, 6
				ELSE
					INSERT INTO EmailCampaignCustomers (EmailCampaignID, GlobalPersonID, EmailCampaignActionID) SELECT @EmailCampaignID, @GPID, 3
			END
		END 
		IF @CustID IS NOT NULL  
		BEGIN	
			--Set customer to active
			IF (SELECT Active FROM Customer WHERE CustID=@CustID)=0
				UPDATE Customer SET Active = 1 WHERE CustID=@CustID
			--Update metro if necessary and enabled
			IF @Rule_UpdateMetro=1
				UPDATE Customer SET MetroAreaID=@MetroAreaID WHERE MetroAreaID<>@MetroAreaID AND CustID<>@CustID
			--Check is UserOptIn record exists for this customer	
			IF EXISTS(SELECT CustID FROM UserOptIn WHERE CustID = @CustID and MetroAreaID = @MetroAreaID)
				--update opt-in bits in DB that are 0 where passed in params are 1 (leave others alone)	
				UPDATE UserOptIn SET 
					Spotlight = ISNULL(@Spotlight, Spotlight), 
					Insider = IsNull(@Insider, Insider),
					DinersChoice = IsNull(@DinersChoice, DinersChoice),
					NewHot = IsNull(@NewHot, NewHot),
					RestaurantWeek = IsNull(@RestaurantWeek, RestaurantWeek),
					Promotional = IsNull(@Promotional, Promotional),
					Product = IsNull(@Product, Product),
					UpdatedDtUTC = getutcdate()
				WHERE 	CustID = @CustID 
				AND ((IsNull(@SpotLight, SpotLight) <> SpotLight)
						  OR (IsNull(@Insider, Insider) <> Insider)
						  OR (IsNull(@DinersChoice, DinersChoice) <> DinersChoice)
						  OR (IsNull(@NewHot, NewHot) <> NewHot)
						  OR (IsNull(@RestaurantWeek, RestaurantWeek) <> RestaurantWeek)
						  OR (IsNull(@Promotional, Promotional) <> Promotional)
						  OR (IsNull(@Product, Product) <> Product))
			ELSE	
				-- insert new record
				INSERT INTO UserOptIn (CustID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID)
					VALUES(@CustID,isnull(@Insider,0),isnull(@DinersChoice,0),isnull(@NewHot,0),isnull(@RestaurantWeek,0),isnull(@Promotional,0),isnull(@Spotlight,0),isnull(@Product,0),@MetroAreaID)		
			IF @@ROWCOUNT=0
				INSERT INTO EmailCampaignCustomers (EmailCampaignID, GlobalPersonID, EmailCampaignActionID) SELECT @EmailCampaignID, @GPID, 6
			ELSE					
				INSERT INTO EmailCampaignCustomers (EmailCampaignID, GlobalPersonID, EmailCampaignActionID) SELECT @EmailCampaignID, @GPID, 2
		END

		-- If user didn't exsist and rule to add anon user = 1 then create user
		IF @CustID is null AND @CallerID is null AND @Rule_AddAnon=1
		BEGIN
			-- Create Email Subscriber (Customer record with anonymous consumer type)
			INSERT INTO CallCusNextID (CustomerType) VALUES (1)

			SELECT @CustID = scope_identity()

			INSERT INTO Customer	
				(CustID	
				,Email	
				,Metroareaid	
				,PartnerID
				,ConsumerType
				,Points)
			VALUES (@CustID,@Email,@MetroAreaID,@PartnerID,8,0) -- 8 = Anonymous 
			
			--Add entry to GlobalPerson
			INSERT	INTO	GlobalPerson (CustID, CallerID) VALUES(@CustID, NULL)

	  		SELECT @GPID = _GlobalPersonID FROM GlobalPerson WHERE CustID = @CustID
			
			-- Create user email Opt In
			INSERT INTO UserOptIn (CustID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID)
				VALUES(@CustID,isnull(@Insider,0),isnull(@DinersChoice,0),isnull(@NewHot,0),isnull(@RestaurantWeek,0),isnull(@Promotional,0),isnull(@Spotlight,0),isnull(@Product,0),@MetroAreaID)	
			INSERT INTO EmailCampaignCustomers (EmailCampaignID, GlobalPersonID, EmailCampaignActionID) SELECT @EmailCampaignID, @GPID, 4
		END -- Create Email Subscriber 
	END TRY
	BEGIN CATCH
		SELECT
		@Err_NUM=ERROR_NUMBER()
        ,@Err_Severity=ERROR_SEVERITY()
        ,@Err_State=ERROR_STATE()
        ,@Err_Msg =ERROR_MESSAGE()+ ' WHILE Processing Email = ' + @Email
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION MyTransaction
		RAISERROR(@Err_Msg,@Err_Severity,@Err_State) --Error adding new Customer.
		RETURN(5)
	END CATCH
	IF @@TRANCOUNT > 0
		COMMIT TRAN

GO

GRANT EXECUTE ON User_EmailCampaign_Add TO ExecuteOnlyRole
GO


