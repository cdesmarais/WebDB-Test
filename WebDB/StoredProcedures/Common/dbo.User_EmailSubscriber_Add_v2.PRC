if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_EmailSubscriber_Add_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_EmailSubscriber_Add_v2]
GO

CREATE Procedure dbo.User_EmailSubscriber_Add_v2
 (  
  @Email nvarchar(255),    
  @PartnerID int,  
  @MetroAreaID int,   
  @Spotlight bit = NULL,
  @Insider bit = NULL,
  @DinersChoice bit = NULL,
  @NewHot bit = NULL,
  @RestaurantWeek bit = NULL,
  @Promotional bit = NULL,
  @Product bit = NULL,
  @IsAdmin bit OUTPUT,
  @UserID int OUTPUT
 )
As
SET NOCOUNT ON

SET @IsAdmin = 0
		
BEGIN TRANSACTION MyTransaction

	IF EXISTS(Select CustID from Customer where email = @email and active = 0)
		GOTO deactivated_Account
	IF EXISTS(Select CustID from Customer where email = @email and ConsumerType = 8)
		GOTO anon_userupdate

	--check for email exists in caller
	IF EXISTS (Select CallerID from Caller where email = @email AND PositionID = 3) 
	BEGIN
		SELECT @UserID = CallerID from Caller where email = @email	AND PositionID = 3
		SET	@IsAdmin = 1
		--Check is UserOptIn record exists for this caller		
		IF EXISTS(SELECT CallerID FROM UserOptIn WHERE CallerID = @UserID and MetroAreaID = @MetroAreaID)
			--update opt-in bits in DB that are 0 where passed in params are 1 (leave others alone)	
			UPDATE UserOptIn SET 
				Spotlight = CASE WHEN @Spotlight is null THEN Spotlight ELSE @Spotlight END, 
				Insider = CASE WHEN @Insider is null THEN Insider ELSE @Insider END,
				DinersChoice = CASE WHEN @DinersChoice is null THEN DinersChoice ELSE @DinersChoice END,
				NewHot = CASE WHEN @NewHot is null THEN NewHot ELSE @NewHot END,
				RestaurantWeek = CASE WHEN @RestaurantWeek is null THEN RestaurantWeek ELSE @RestaurantWeek END,
				Promotional = CASE WHEN @Promotional is null THEN Promotional ELSE @Promotional END,
				Product = CASE WHEN @Product is null THEN Product ELSE @Product END,
				UpdatedDtUTC = getutcdate()
			WHERE	CallerID = @UserID 
					AND MetroAreaID = @MetroAreaID  
					AND (
							( (@SpotLight | SpotLight) <> SpotLight AND @Spotlight IS NOT NULL)
						  OR ((Insider | @Insider) <> Insider AND @Insider IS NOT NULL)
						  OR ((DinersChoice | @DinersChoice) <> DinersChoice AND @DinersChoice  IS NOT NULL)
						  OR ((NewHot | @NewHot) <> NewHot AND @NewHot  IS NOT NULL)
						  OR ((RestaurantWeek | @RestaurantWeek) <> RestaurantWeek AND @RestaurantWeek IS NOT NULL)
						  OR ((Promotional | @Promotional) <> Promotional AND @Promotional IS NOT NULL)
						  OR ((Product | @Product) <> Product AND @Product  IS NOT NULL)
						)
		ELSE	
			-- insert new record
			INSERT INTO UserOptIn (CallerID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID)
				VALUES(@UserID,isnull(@Insider,0),isnull(@DinersChoice,0),isnull(@NewHot,0),isnull(@RestaurantWeek,0),isnull(@Promotional,0),isnull(@Spotlight,0),isnull(@Product,0),@MetroAreaID)	

		IF (@@ERROR <> 0) 
			GOTO general_error	
	END 
	ELSE IF EXISTS(Select CustID from Customer where email = @email)  
	-- email exists in customer
	BEGIN
		SELECT @UserID = CustID from Customer where email = @email	
		--Check is UserOptIn record exists for this customer		
		IF EXISTS(SELECT CustID FROM UserOptIn WHERE CustID = @UserID and MetroAreaID = @MetroAreaID)
			--update opt-in bits in DB that are 0 where passed in params are 1 (leave others alone)	
			UPDATE UserOptIn SET 
				Spotlight = CASE WHEN @Spotlight is null THEN Spotlight ELSE @Spotlight END, 
				Insider = CASE WHEN @Insider is null THEN Insider ELSE @Insider END,
				DinersChoice = CASE WHEN @DinersChoice is null THEN DinersChoice ELSE @DinersChoice END,
				NewHot = CASE WHEN @NewHot is null THEN NewHot ELSE @NewHot END,
				RestaurantWeek = CASE WHEN @RestaurantWeek is null THEN RestaurantWeek ELSE @RestaurantWeek END,
				Promotional = CASE WHEN @Promotional is null THEN Promotional ELSE @Promotional END,
				Product = CASE WHEN @Product is null THEN Product ELSE @Product END,
				UpdatedDtUTC = getutcdate()
			WHERE 	CustID = @UserID 
					AND MetroAreaID = @MetroAreaID
					AND (
							( (@SpotLight | SpotLight) <> SpotLight AND @Spotlight IS NOT NULL)
						  OR ((Insider | @Insider) <> Insider AND @Insider IS NOT NULL)
						  OR ((DinersChoice | @DinersChoice) <> DinersChoice AND @DinersChoice  IS NOT NULL)
						  OR ((NewHot | @NewHot) <> NewHot AND @NewHot  IS NOT NULL)
						  OR ((RestaurantWeek | @RestaurantWeek) <> RestaurantWeek AND @RestaurantWeek IS NOT NULL)
						  OR ((Promotional | @Promotional) <> Promotional AND @Promotional IS NOT NULL)
						  OR ((Product | @Product) <> Product AND @Product  IS NOT NULL)
						)
		ELSE	
			-- insert new record
			INSERT INTO UserOptIn (CustID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID)
				VALUES(@UserID,isnull(@Insider,0),isnull(@DinersChoice,0),isnull(@NewHot,0),isnull(@RestaurantWeek,0),isnull(@Promotional,0),isnull(@Spotlight,0),isnull(@Product,0),@MetroAreaID)	

		IF (@@ERROR <> 0) 
			GOTO general_error		
	END ELSE  BEGIN
		-- Create Email Subscriber (Customer record with anonymous consumer type)
		INSERT INTO CallCusNextID (CustomerType) VALUES (1)
		
		IF (@@ERROR <> 0) 
			GOTO general_error
		
		SELECT @UserID = scope_identity()

		INSERT INTO Customer	
			(CustID	
			,Email	
			,Metroareaid	
			,PartnerID
			,ConsumerType
			,Points)
		VALUES (@UserID,@Email,@MetroAreaID,@PartnerID,8,0) -- 8 = Anonymous
		
		IF (@@ERROR <> 0) 
			GOTO general_error    
		
		--Add entry to GlobalPerson
		INSERT	INTO	GlobalPerson (CustID, CallerID) VALUES(@UserID, NULL)
		IF (@@ERROR <> 0) 
			GOTO general_error    
		
		-- Create user email Opt In
		INSERT INTO UserOptIn (CustID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID)
			VALUES(@UserID,isnull(@Insider,0),isnull(@DinersChoice,0),isnull(@NewHot,0),isnull(@RestaurantWeek,0),isnull(@Promotional,0),isnull(@Spotlight,0),isnull(@Product,0),@MetroAreaID)	
		
		IF (@@ERROR <> 0) 
			GOTO general_error   
		
	END -- Create Email Subscriber 

	COMMIT TRAN
	RETURN(0)

anon_userupdate:
	
	Select @UserID = CustID from Customer where email = @email and ConsumerType = 8
	
	--Check is UserOptIn record exists for this customer		
	IF EXISTS(SELECT CustID FROM UserOptIn WHERE CustID = @UserID and MetroAreaID = @MetroAreaID)
		--update opt-in bits in DB that are 0 where passed in params are 1 (leave others alone)	
		UPDATE UserOptIn SET 
				Spotlight = CASE WHEN @Spotlight is null THEN Spotlight ELSE @Spotlight END, 
				Insider = CASE WHEN @Insider is null THEN Insider ELSE @Insider END,
				DinersChoice = CASE WHEN @DinersChoice is null THEN DinersChoice ELSE @DinersChoice END,
				NewHot = CASE WHEN @NewHot is null THEN NewHot ELSE @NewHot END,
				RestaurantWeek = CASE WHEN @RestaurantWeek is null THEN RestaurantWeek ELSE @RestaurantWeek END,
				Promotional = CASE WHEN @Promotional is null THEN Promotional ELSE @Promotional END,
				Product = CASE WHEN @Product is null THEN Product ELSE @Product END,
				UpdatedDtUTC = getutcdate()
		WHERE 	CustID = @UserID  
				AND MetroAreaID = @MetroAreaID
				AND (
							( (@SpotLight | SpotLight) <> SpotLight AND @Spotlight IS NOT NULL)
						  OR ((Insider | @Insider) <> Insider AND @Insider IS NOT NULL)
						  OR ((DinersChoice | @DinersChoice) <> DinersChoice AND @DinersChoice  IS NOT NULL)
						  OR ((NewHot | @NewHot) <> NewHot AND @NewHot  IS NOT NULL)
						  OR ((RestaurantWeek | @RestaurantWeek) <> RestaurantWeek AND @RestaurantWeek IS NOT NULL)
						  OR ((Promotional | @Promotional) <> Promotional AND @Promotional IS NOT NULL)
						  OR ((Product | @Product) <> Product AND @Product  IS NOT NULL)
					)
	ELSE	
		-- insert new record
		INSERT INTO UserOptIn (CustID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID)
			VALUES(@UserID,isnull(@Insider,0),isnull(@DinersChoice,0),isnull(@NewHot,0),isnull(@RestaurantWeek,0),isnull(@Promotional,0),isnull(@Spotlight,0),isnull(@Product,0),@MetroAreaID)	

	IF (@@ERROR <> 0) 
		GOTO general_error

	COMMIT TRAN
	RETURN(0)

-- Handle Error cases.
general_error:
	ROLLBACK TRANSACTION MyTransaction
	RAISERROR('6',16,2) --Error adding new Customer.
	RETURN(5)

deactivated_Account:
	ROLLBACK TRANSACTION MyTransaction
	RAISERROR('141',16,2) --Deactivated Account
	RETURN(5)
GO

GRANT EXECUTE ON [User_EmailSubscriber_Add_v2] TO ExecuteOnlyRole
GO

