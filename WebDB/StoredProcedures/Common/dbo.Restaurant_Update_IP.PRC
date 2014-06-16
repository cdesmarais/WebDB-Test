--*****************
--** NOTE: This just updates the IP Address provided it's not in the filter set
--** Only called by DNRestaurantUpdateERB (should be incorporated into that proc directly)
--*****************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Update_IP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Update_IP]
GO

CREATE Procedure dbo.Restaurant_Update_IP 
 (               
	 @Server_IP     nvarchar(255)
    ,@Erb_Build     nvarchar(50)
    ,@Version       nvarchar(50)
    ,@Restaurant_ID int
	,@RetVal	int = 0 OUTPUT
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

DECLARE @ERBBuild int
		,@curr_ip nvarchar(255)
		,@curr_build nvarchar(50)
		,@curr_version nvarchar(50)
		,@StaticIPAddress int		
		,@newIP nvarchar(255)
		,@newErbBuild nvarchar(50)
		,@newLVersion nvarchar(50)
		,@IsInternalIP int

  IF NOT EXISTS (Select 1
           From   Restaurant 
           Where  RID = @Restaurant_ID 
           And    Ping          = 0
          ) 
  begin
	-- if PING is not set then we dont need to update IP addresses..
	Goto no_need_to_update_IP 
  end
  	
exec @IsInternalIP = dbo.Restaurant_IsInternalIP @Server_IP
IF (@IsInternalIP = 1)
BEGIN
	GOTO InternalIP_error
END
	
select 	  @curr_ip = ServerIP
	,@curr_build = ERBBuild
	,@curr_version = version
	, @StaticIPAddress = StaticIPAddress
from ERBRestaurant
where	RID = @Restaurant_ID
option (keepfixed plan)

if @StaticIPAddress = 1
BEGIN
	Set @Server_IP = @curr_ip
END

--*****************
--** Just update IP Address
--** update of version number temproraily disabled
--*****************
if  (@Server_IP <> @curr_ip) or (@curr_ip is null)
begin
		UPDATE ERBRestaurant 
		SET    	ServerIP  = @Server_IP
	    WHERE  RID = @Restaurant_ID
		option (keepfixed plan)	    
end


/*
--*****************
--** update of version number temproraily disabled
--*****************
if (@Erb_Build = '0' Or @Erb_Build Is Null) 
	BEGIN
	  Set @ERBBuild =  @curr_build
	END
else	
	BEGIN
	if @Erb_Build = '1.00'
		begin
			Set @ERBBuild = 1
		END
	else
		if @Erb_Build = '136b'
			BEGIN
				Set @ERBBuild = 136
			END
		else
			BEGIN
				Set @ERBBuild = convert(int,@Erb_Build)
			end
	END


if  (@Server_IP <> @curr_ip) or
	( (@Erb_Build <> @curr_build) and (@Erb_Build <> '') ) or
	( (@version <> @curr_version) and (@version <> '') )
	BEGIN
		set @newIP       = @curr_ip
		set @newErbBuild = @curr_build
		set @newLVersion = @curr_version
		
		if (@Server_IP <> @curr_ip)                           set @newIP       = @Server_IP
		if (@Erb_Build <> @curr_build) and (@Erb_Build <> '') set @newErbBuild = @ERBBuild
		if (@version <> @curr_version) and (@version <> '')   set @newLVersion = @version
		
		UPDATE ERBRestaurant 
		SET    	ServerIP           = @newIP
	      		,ERBBuild          = @newErbBuild
	    		,version           = @newLVersion
	    WHERE  RID = @Restaurant_ID
		option (keepfixed plan)	    
	END
*/
	
if(@@ERROR <> 0) Goto general_error

no_need_to_update_IP:
set @RetVal = 1
RETURN(0)

updateIP_error:

RAISERROR ('55',17,16)
RETURN(1)

general_error:

RAISERROR('56',17,1)
RETURN(2)

InternalIP_error:

RAISERROR('Error - Internal IP Address, ignoring...', 17, 1)
RETURN(3)

GO

GRANT EXECUTE ON [Restaurant_Update_IP] TO ExecuteOnlyRole

GO
