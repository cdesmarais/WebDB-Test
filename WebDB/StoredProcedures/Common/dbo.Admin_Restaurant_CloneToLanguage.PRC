if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_CloneToLanguage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_CloneToLanguage]
GO

CREATE Procedure dbo.Admin_Restaurant_CloneToLanguage
(
    @RestaurantID int,
    @LanguageID int
)
As
SET NOCOUNT ON

  DECLARE  @ProcName  AS NVARCHAR(1000)
  DECLARE  @Action  AS NVARCHAR(3000)
  DECLARE  @DBError INT
  DECLARE  @RestPrimaryLanguage INT
  DECLARE  @RestaurantName AS NVARCHAR(255)
  
  SET @ProcName = 'Admin_Restaurant_CloneToLanguage'
  SET @Action = 'Proc Started'
  
  BEGIN TRANSACTION
  
  --*******************************
--** Validate that this restaurant can be cloned
--*******************************

set @Action = 'Validate local Restaurant info does not exist'
if EXISTS (SELECT rid FROM restaurantlocal WHERE  rid = @RestaurantID AND languageid = @LanguageID)
	goto error

set @Action = 'Validate neighborhood, region and metro info exists'
if NOT EXISTS (SELECT [RID] FROM [Restaurant]
			INNER JOIN [NeighborhoodAVW] ON [Restaurant].[NeighborhoodID] = [NeighborhoodAVW].[NeighborhoodID]
			WHERE [RID] = @RestaurantID AND [LanguageID] = @LanguageID
			)
	goto error
	
	SELECT @RestPrimaryLanguage = PrimaryLanguageID
	FROM dbo.Restaurant r
	INNER JOIN dbo.Domain d
	ON r.DomainID = d.DomainID
	WHERE r.RID = @RestaurantID
	
	SELECT @RestaurantName = [rname]
	FROM dbo.RestaurantLocal r
	WHERE r.RID = @RestaurantID AND r.languageid = @RestPrimaryLanguage

	--**************************************
	--** Log Name change
	--**************************************
	set @Action = 'Log Restaurant name change'
	insert into RestNameChange (RID, LanguageID, ResoRname, EffectiveDT)
	values (@RestaurantID, @LanguageID, @RestaurantName, '01-01-1900') --default expireDT 01-01-9999
	set @DBError = @@error
	if @DBError <> 0
		goto error

	SET @Action = 'Copy RestaurantLocal info'
	INSERT INTO [restaurantlocal]
			   ([rid],
				[languageid],
				[rname],
				[address1],
				[address2],
				[city],
				[state],
				[chef],
				[banquetcontact],
				[crossstreet],
				[privatepartycontact],
				[rsname],
				[IsActive])
	SELECT
	  rid,
	  @LanguageID AS [languageid],
	  [rname],
	  [address1],
	  [address2],
	  [city],
	  [state],
	  [chef],
	  [banquetcontact],
	  [crossstreet],
	  [privatepartycontact],
	  [rsname],
	  0
	FROM   
	  restaurantlocal
	WHERE  rid = @RestaurantID
	AND LanguageID = @RestPrimaryLanguage

	SET @Action = 'Copy RestaurantCustomMessage info'
	INSERT INTO [RestaurantCustomMessage] (
		[RID],
		[MessageTypeID],
		[Message],
		[LanguageID]) 
	Select RID,
		MessageTypeID,
		Message,
		@LanguageID as LanguageID
	FROM [RestaurantCustomMessage]
		where RID = @RestaurantID
		AND LanguageID = @RestPrimaryLanguage
		AND MessageTypeID NOT IN (SELECT MessageTypeID 
									FROM RestaurantCustomMessage 
									WHERE rid = @RestaurantID 
									AND LanguageID = @LanguageID)

	SET @Action = 'Set Reservation Confirmation message to default'
	UPDATE [RestaurantCustomMessage]
	SET [Message] = 
		(SELECT	REPLACE(Message,'[RestaurantName]',
			(SELECT RName
			FROM dbo.RestaurantLocal
			WHERE RID = @RestaurantID
			AND LanguageID = @LanguageID)) AS Message
		FROM 	[DefaultMessage] 
		WHERE 	[MessageTypeID] = 16 -- Default Confirmation Message is Message ID 16
		AND 	[LanguageID] = @LanguageID)
	WHERE	RID = @RestaurantID
	AND	MessageTypeID = 10 -- Confirmation Message is Message ID 10
	AND	LanguageID = @LanguageID
	
	/* If Cloning from US to Mexico, we can just take existing food types and add 600 */
	if @LanguageID = 6
	BEGIN
		INSERT INTO [foodtypes]
				   ([rid],
					[foodtypeid],
					[isprimary],
					[ftrank])
		SELECT
		  rid,
		  ([foodtypeid] + 600) as foodtypeid,
		  [isprimary],
		  ftrank
		FROM     
		  [foodtypes]
		  where rid = @RestaurantID and [foodtypeid]  < 100
	
	
	END
	else
	BEGIN

		/* Add first primary food type in Language as place holder for this restaurant. */
		INSERT INTO [foodtypes]
				   ([rid],
					[foodtypeid],
					[isprimary],
					[ftrank])
		SELECT TOP 1
		  @RestaurantID AS rid,
		  [foodtype].[foodtypeid],
		  1 AS [isprimary],
		  1 AS ftrank
		FROM     
		  [foodtype]
		  INNER JOIN [foodtypesearchmap]
			ON [foodtype].[foodtypeid] = [foodtypesearchmap].[foodtypeid]
			   AND [foodtype].[foodtypeid] = [foodtypesearchmap].[searchfoodtypeid]
		WHERE    [languageid] = @LanguageID
		ORDER BY [foodtype].[foodtypeid]
	
	
	END
	
	
	INSERT INTO blockeddayLocal
	(DayID, Message, LanguageID)
	SELECT [BlockedDay].DayID, [BlockedDayLocal].Message, @LanguageID AS LanguageID
	FROM [BlockedDay]
	INNER JOIN [BlockedDayLocal] ON [BlockedDay].[DayID] = [BlockedDayLocal].dayID
	WHERE rid = @RestaurantID
	AND LanguageID = @RestPrimaryLanguage

	INSERT INTO [customedDayLocal]
	(DayID, Message, LanguageID)
	SELECT [customedDay].DayID, [customedDayLocal].Message, @LanguageID AS LanguageID
	FROM [customedDay]
	INNER JOIN [customedDayLocal] ON [customedDay].[DayID] = [customedDayLocal].dayID
	WHERE rid = @RestaurantID
	AND LanguageID = @RestPrimaryLanguage
	
	
	

COMMIT TRANSACTION
Return(0)

error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(1)

GO


GRANT EXECUTE ON [Admin_Restaurant_CloneToLanguage] TO ExecuteOnlyRole

GO
