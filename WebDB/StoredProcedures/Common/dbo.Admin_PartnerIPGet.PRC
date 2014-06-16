if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerIPGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerIPGet]
go


create procedure dbo.Admin_PartnerIPGet(
			@partnerid int
)
as

set nocount on
set transaction isolation level read uncommitted

	select		IPAddress 
	from		partnerips
	where		PartnerID = @partnerid
	order by 	IPAddress 

go

grant execute on [Admin_PartnerIPGet] to ExecuteOnlyRole

go

