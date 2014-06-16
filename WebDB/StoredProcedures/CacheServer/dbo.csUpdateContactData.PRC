--$ create proc csUpdateContactData
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csUpdateContactData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csUpdateContactData]
GO

CREATE PROCEDURE dbo.csUpdateContactData
(
	 @RID					int
	,@bUnpingSet			int
	,@sIPAndPort			varchar(255)
	,@sOTLVersion			varchar(50)
	,@bIsInventory			bit	 = 0
)
As

	declare	 @ServerIP			varchar(255)
			,@ERBVersion		varchar(50)
			,@ListenerVersion	varchar(50)
			,@bStateUpdated		bit
			,@IsEMH_IP			bit = 0
			,@IP				VARCHAR(255)
			
	------------------------------------------------------------------------------
	-- UPDATE restaurant state based on unping
	-- Note: Only toggle between 'active' and 'updating book'
	------------------------------------------------------------------------------
	set @bStateUpdated = 0
	
	if (@bUnpingSet = 1)
	BEGIN
		update	Restaurant
		set		RestStateID = 13 -- updating book
		where	RID = @RID
		and		RestStateID = 1  -- active
	
		set @bStateUpdated = @@rowcount
	
		if (@bStateUpdated = 1)
		BEGIN
			-- track change to 13 (Updating Book)
			EXEC dbo.Admin_AuditRestStatusChg @RID, 'CacheServer(Auto)', 13
		END
	END
	else
	BEGIN
		update	Restaurant
		set		RestStateID = 1  -- active
		where	RID = @RID
		and		RestStateID = 13 -- updating book

		set @bStateUpdated = @@rowcount

		if (@bStateUpdated = 1)
		BEGIN
			-- track change to 1 (Active)
			EXEC dbo.Admin_AuditRestStatusChg @RID, 'CacheServer(Auto)', 1
		END
	END

	if(@@ERROR <> 0) GOTO general_error

	------------------------------------------------------------------------------
	--Check for EMH IPAddresses. EMH IP should not be stored as ERB IP
	------------------------------------------------------------------------------
	--Strip Port Number 
	SET @IP = SUBSTRING(COALESCE(@sIPAndPort,  ''), 0, CHARINDEX(':', COALESCE(@sIPAndPort,  '')))
	--Check if the IPAddress is an EMH server ipaddress
	IF EXISTS ( SELECT 1 FROM EMHServer WITH (NOLOCK) WHERE IPAddress = @IP )
		SET @IsEMH_IP = 1
	
	------------------------------------------------------------------------------
	-- UPDATE ERBRestaurant
	------------------------------------------------------------------------------
	update	ERBRestaurant
	set			ServerIP			= (case when StaticIPAddress = 0 and (coalesce(@sIPAndPort,  '') <> '' and @IsEMH_IP = 0)
										then @sIPAndPort
										else ServerIP
										end),
				ERBVersion			= (case when (coalesce(@sOTLVersion, '') <> '')
										then @sOTLVersion
										else ERBVersion
										end),
				ListenerVersion		= (case when (coalesce(@sOTLVersion, '') <> '')
										then @sOTLVersion
										else ListenerVersion
										end),
				IsInventory			= @bIsInventory
	where	RID = @RID
		and (
			not ( -- Prevent Blind writes
						ServerIP			= (case when StaticIPAddress = 0 and (coalesce(@sIPAndPort,  '') <> '')
												then @sIPAndPort
												else ServerIP
												end)
				and		ERBVersion			= (case when (coalesce(@sOTLVersion, '') <> '')
												then @sOTLVersion
												else ERBVersion
												end)
				and		ListenerVersion		= (case when (coalesce(@sOTLVersion, '') <> '')
												then @sOTLVersion
												else ListenerVersion
												end)
				and		IsInventory			= @bIsInventory
		)
		-- If any of the current values are null then perform a blind
		-- write; this should only occur when the record is first created
		or ServerIP is null 
		or ERBVersion is null 
		or ListenerVersion is null
	)
	if(@@ERROR <> 0) GOTO general_error
	
	RETURN(0)


general_error:

	RAISERROR('56', 17, 1)
	RETURN(2)

GO
GRANT EXECUTE ON [csUpdateContactData] TO ExecuteOnlyRole
GO
