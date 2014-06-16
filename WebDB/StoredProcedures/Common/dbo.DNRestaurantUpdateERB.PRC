if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantUpdateERB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantUpdateERB]
GO


CREATE PROCEDURE dbo.DNRestaurantUpdateERB
 (
  @RID int,
  @ErbVersion nvarchar(50),
  @OTLVersion nvarchar(50),
  @IPAddr nvarchar(50),
  @Unping int
 )
As



DECLARE @Cur_ERBVersion nvarchar(50), @Cur_OTLVersion nvarchar(50),
		@newErbBuild nvarchar(50), @newLVersion nvarchar(50),
		@updateRetVal int

-- Update the Version number and IP Address
exec Restaurant_Update_IP  @IPAddr ,@ErbVersion ,@OTLVersion,@RID , @updateRetVal OUTPUT

declare @bStateUpdated	bit
	
if @Unping = 1
BEGIN
	
	-- update restaurant state only if state is ACTIVE, if its not ACTIVE then dont change it for updating book,else we'll lose the status change
	update Restaurant
	set restStateID = 13
	where RID = @RID 
	and restStateID = 1
	option (keepfixed plan)

	set @bStateUpdated = @@rowcount

	if (@bStateUpdated = 1)
	BEGIN
		-- track change to 13 (Updating Book)				
		EXEC dbo.Admin_AuditRestStatusChg @RID,'Website4.0(Auto)',13
	END							
	
END

ELSE

BEGIN
	select @Cur_ERBVersion = coalesce(ERBVersion,'')
		, @Cur_OTLVersion = coalesce(ListenerVersion,'')
		from erbrestaurant
	where	rid = @RID

	-- update state if required
	update restaurant
	set reststateID = 1
	where RID = @RID
	and restStateID = 13
	option (keepfixed plan)
	
	set @bStateUpdated = @@rowcount
							
	if (@bStateUpdated = 1)
	BEGIN
		-- track changes to ACTIVE from UPDATING BOOK
		EXEC dbo.Admin_AuditRestStatusChg @RID,'Website4.0(Auto)',1
	END
	

-- Update the ERBVersion and ListenerVersion fields..
	if ((@ErbVersion <> @Cur_ERBVersion)) or	((@OTLVersion <> @Cur_OTLVersion))
	BEGIN
		set @newErbBuild = @Cur_ERBVersion
		set @newLVersion = @Cur_OTLVersion
		
		-- akash: if the erbversion and listenerversion are empty strings from the upstream 
		-- call it should be counted as a difference
		if (@ErbVersion <> @Cur_ERBVersion) set @newErbBuild = @ErbVersion
		if (@OTLVersion <> @Cur_OTLVersion) set @newLVersion = @OTLVersion
		
		-- if values are EMPTY strings then set to null
		if(@newErbBuild = '')set @newErbBuild=null
		if(@newLVersion = '')set @newLVersion=null
		
		update erbrestaurant
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


GRANT EXECUTE ON [DNRestaurantUpdateERB] TO ExecuteOnlyRole

GO
