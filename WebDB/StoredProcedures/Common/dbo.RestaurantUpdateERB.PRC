if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantUpdateERB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantUpdateERB]
GO

CREATE Procedure dbo.RestaurantUpdateERB
 (
  @RID int,
  @ErbVersion nvarchar(50),
  @OTLVersion nvarchar(50),
  @OldERBBuild nvarchar(50), -- not used anymore...
  @OldOTLVersion nvarchar(50), -- not used anymore...
  @IPAddr nvarchar(50),
  @Unping int
 )
As

DECLARE @Cur_ERBVersion nvarchar(50), @Cur_OTLVersion nvarchar(50),
		@newErbBuild nvarchar(4), @newLVersion nvarchar(4)
if @Unping = 1
BEGIN
	update Restaurant
	set RestStateID = 13
	where RID = @RID and RestStateID = 1
END
else
BEGIN
	select @Cur_ERBVersion = coalesce(ERBVersion,'')
		, @Cur_OTLVersion = coalesce(ListenerVersion,'')
		from ERBRestaurant
	where	RID = @RID

	-- Reset the status if it was updating it's books
	update restaurant
	set RestStateID = 1
	where RID = @RID
	and RestStateID = 13
	option (keepfixed plan)
	
	-- status tracking
	declare @bStateUpdated bit
	set @bStateUpdated = @@rowcount
	
	if (@bStateUpdated = 1)
	BEGIN
		-- track change 
		EXEC dbo.Admin_AuditRestStatusChg @RID,'Website4.0(Auto)',1
	END

	--if (left(@OTListenerVersion,3) = '4.5')
	--BEGIN
	--	update erb_restaurant set product_ID = 8 where Restaurant_ID = @RID and product_ID < 8
	--END
	
	if ( (@ErbVersion <> @Cur_ERBVersion) and (@ErbVersion <> '') ) or
		( (@OTLVersion <> @Cur_OTLVersion) and (@OTLVersion <> '') )
	BEGIN
		set @newErbBuild = @Cur_ERBVersion
		set @newLVersion = @Cur_OTLVersion
		
		if (@ErbVersion <> @Cur_ERBVersion) and (@ErbVersion <> '') set @newErbBuild = @ErbVersion
		if (@OTLVersion <> @Cur_OTLVersion) and (@OTLVersion <> '') set @newLVersion = @OTLVersion
		
		update ERBRestaurant
		set ErbVersion = @newErbBuild, ListenerVersion = @newLVersion
		where RID = @RID
	END

END


if(@@ERROR <> 0) Goto general_error

RETURN(0)


general_error:

RAISERROR('56', 17, 1)
RETURN(2)
GO

GRANT EXECUTE ON [RestaurantUpdateERB] TO ExecuteOnlyRole

GO
