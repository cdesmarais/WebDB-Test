if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerIPDelete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerIPDelete]
go

create procedure dbo.Admin_PartnerIPDelete(
			@partnerid int,
			@IPAddress varchar(30)			
)
as

set nocount on

	delete 
	from	partnerIPs
	where	PartnerID = @partnerid
	and		IPAddress = @IPAddress

if @@error <> 0  
  goto general_error 
  
return(0) 

general_error:  
	return(1) 
go

grant execute on [Admin_PartnerIPDelete] to ExecuteOnlyRole

go

