if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Update_IP2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Update_IP2]
GO

CREATE PROCEDURE dbo.Restaurant_Update_IP2 
 (               
	 @ServerIP     nvarchar(255)
    ,@ERBBuild     nvarchar(50)
    ,@Version       nvarchar(50)
    ,@RID int
	,@RetVal	int = 0 OUTPUT
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

DECLARE  @ERBBuild2 int
	,@curr_ip nvarchar(255)
	,@curr_build nvarchar(50)
	,@curr_Version nvarchar(50)
	,@StaticIPAddress int
	,@newIP nvarchar(255)
	,@newErbBuild nvarchar(50)
	,@newLVersion nvarchar(50)
	,@IsInternalIP int
if NOT EXISTS (Select 1 From  Restaurant where  RID = @RID And  Ping  = 0) 
Goto updateIP_error

exec @IsInternalIP = dbo.Restaurant_IsInternalIP @ServerIP

if (@IsInternalIP = 1)
	BEGIN
		GOTO InternalIP_error
	END

select 	  @curr_ip = ServerIP
	, @curr_build = ERBBuild
	, @curr_Version = Version
	, @StaticIPAddress = StaticIPAddress
from ERBRestaurant
where	RID = @RID
option (keepfixed plan)
if @StaticIPAddress = 1
BEGIN
Set @ServerIP = @curr_ip
END
if (@ERBBuild = '0' Or @ERBBuild Is Null) 
BEGIN
	Set @ERBBuild =  @curr_build
END
else	
BEGIN

if @ERBBuild = '1.00'
	begin
		Set @ERBBuild = 1
	END
else
			if @ERBBuild = '136b'
				BEGIN
					Set @ERBBuild = 136
				END
			else
				BEGIN
					Set @ERBBuild = convert(int, @ERBBuild) 
				end
	END

if (@ServerIP <> @curr_ip) or
	( (@ERBBuild <> @curr_build) and (@ERBBuild <> '') ) or
	( (@Version <> @curr_Version) and (@Version <> '') )
	BEGIN
		set @newIP       = @curr_ip
		set @newErbBuild = @curr_build
		set @newLVersion = @curr_Version
		
		if (@ServerIP <> @curr_ip)                           set @newIP       = @ServerIP
		if (@ERBBuild <> @curr_build) and (@ERBBuild <> '') set @newErbBuild = @ERBBuild
		if (@Version <> @curr_Version) and (@Version <> '')   set @newLVersion = @Version
		
		UPDATE ERBRestaurant 
		SET    	ServerIP           = @newIP
	      		,ERBBuild          = @newErbBuild
	    		,Version            = @newLVersion
	    WHERE  RID = @RID
option (keepfixed plan)
	END
if(@@ERROR <> 0) Goto general_error

set @RetVal = 1
RETURN(0)

updateIP_error:

RAISERROR ('55', 17,16)
RETURN(1)

general_error:

RAISERROR('56', 17, 1)
RETURN(2)

InternalIP_error:

RAISERROR('Error - Internal IP Address, ignoring...', 17, 1)
RETURN(3)


GO

GRANT EXECUTE ON [Restaurant_Update_IP2] TO ExecuteOnlyRole

GO
