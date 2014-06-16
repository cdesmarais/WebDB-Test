

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateServerInfo2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateServerInfo2]
GO


create procedure [dbo].[Admin_Restaurant_UpdateServerInfo2]
(
	@RestaurantID int
	,@ServerIPAddress nvarchar(255)
	,@ServerPass nvarchar(255)
	,@StaticIP int
	,@RestaurantStateID int
	,@IsOptOutForFRNandBackSoon bit
	,@CHARMUserName	nvarchar(100) 
	,@ERBVersion varchar(50) 
	,@RestStateIDListToUpdateERB varchar(50)
	,@IsOptOutEmailForFRNandBackSoon bit
 )
as

/*
	This SP is used to update Restaurnat connectivity settings like IPAddress, Restaurant state, Serverpass, ERBVersion....
	If ERBVersion has been changed w.r.t current ERBVersion then it add adudit log for ERBVersion.
*/

declare @CurrERBVersion varchar(50)
declare @CurrRestStateID int
declare @CurrIsReachable bit

-- strore current ERBVersion in local variable
select	
	@CurrERBVersion = ERBVersion
from 
	[ERBRestaurant]
where 
	[RID] = @RestaurantID


update 	
	[ERBRestaurant]
set 	
	[ServerIP] = @ServerIPAddress
	,[StaticIPAddress] = @StaticIP
	,[ServerPwd] = @ServerPass
where 	
	[RID] = @RestaurantID

-- If ERBVersion has been chnge w.r.t current version and ERBVersion is not null then update ERBVersion. 
if coalesce(@CurrERBVersion,'') <> coalesce(@ERBVersion,'')  and @ERBVersion is not null 
begin

	-- Get the latest restaurnt state form the Restarunt table . Here we can get the restaurnt state from the RestStateID column.
	-- But there is one special case, if Restaurnt is in BackSoon state that time isReachable should be zero. so get the latest Isreachable bit
	select 
		@CurrIsReachable = isReachable
		,@CurrRestStateID = RestStateID
	from 
		[Restaurant] 
	where 
		RID = @RestaurantID
		
	/*
		Update ERBVersion Provided Currrent state of the restaurant belongs to list for which ERB vesion updated is allowed.
		Today ERBVersion is allowed to update only if restaurnt is in following states
			1. BackSoon. (We don't store this state as it is. We have to derive it from Restaurant state (i.e. staue shopuld be Active)
						  and ISreachable bit from restaurant table must be 0)
			2. No Connectivity Available state
			3. Decline online w/o Conn
	*/
	if exists (select ID from dbo.fIDStrToTab(@RestStateIDListToUpdateERB,',') where ID  = @CurrRestStateID )
	begin

		if ((@CurrRestStateID = 1 and @CurrIsReachable = 0) or @CurrRestStateID<>1)
		begin
			
			-- Update ERBVersion
			update 	
				[ERBRestaurant]
			set 
				[ERBVersion] = @ERBVersion
			where 	
				[RID] = @RestaurantID
			
			-- Add Adudit log for ERBVersion
			exec AddERBVersionOverrideAuditLog @RestaurantID,@CurrERBVersion,@ERBVersion,@CHARMUserName
		end
	end
	
end


update
	[Restaurant]
set
	[RestStateID] = @RestaurantStateID
	,[IsOptOutForFRNandBackSoon] = @IsOptOutForFRNandBackSoon
	,[IsOptOutEmailForFRNandBackSoon]=@IsOptOutEmailForFRNandBackSoon
where
	[RID] = @RestaurantID

-- If this restaurant is being set to inactive and the publish flag is set, unpublish and log
IF EXISTS (SELECT PublishPrivateDining FROM dbo.Restaurant where RID = @RestaurantID and PublishPrivateDining = 1) and @RestaurantStateID = 4
BEGIN
	Update Restaurant set  PublishPrivateDining = 0 where rid = @RestaurantID
	
		
	INSERT INTO dbo.PrivateDiningUpdateLog (
		RID,
		UpdateLogDTUTC,
		UpdatedBy,
		UpdatedValues,
		ApprovedDTUTC,
		ApprovedBy,
		SubmittedFromOTR,
		IsSubmitted,
		LanguageId
	) VALUES ( 
		/* RID - int */ @RestaurantID,
		/* UpdateLogDTUTC - datetime */ current_timestamp,
		/* UpdatedBy - nvarchar(500) */ @CHARMUserName + ' by setting restaurant to Inactive',
		/* UpdatedValues - text */ '<?xml version="1.0"?><root><PDInfo><Published><![CDATA[False]]></Published></PDInfo><Rooms /></root>',
		/* ApprovedDTUTC - datetime */ current_timestamp,
		/* ApprovedBy - nvarchar(500) */ @CHARMUserName + ' by setting restaurant to Inactive',
		/* SubmittedFromOTR - bit */ 0,
		/* IsSubmitted - bit */ 1,
		/* LanguageId - int */ 0 ) 
			

END
	
	
GO

grant execute on [Admin_Restaurant_UpdateServerInfo2] to ExecuteOnlyRole

GO


