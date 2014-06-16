if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerIPAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerIPAdd]
GO


CREATE PROCEDURE dbo.Admin_PartnerIPAdd (			
			@PartnerID int,
			@IPAddress varchar(30)
)
as

set nocount on
  
if exists(select partnerid from partnerips where ipaddress = @IPAddress and partnerid = @PartnerID) 
	goto ip_exists
  
	insert into partnerips (
				PartnerID,
				IPAddress)
	values (
				@PartnerID,
				@IPAddress)
						
if @@Error <> 0  
	goto error  
		
return(0)
  
error:
	raiserror('error inserting ip address for partner',16,1)
	return(1)
	
ip_exists:
	return(1)
	
	  
GO

grant execute on [Admin_PartnerIPAdd] to ExecuteOnlyRole

GO

