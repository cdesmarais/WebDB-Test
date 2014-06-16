if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerTypeGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerTypeGet]
go

create procedure dbo.Admin_PartnerTypeGet
as

set nocount on
set transaction isolation level read uncommitted
  
	select		PartnerTypeID, 
				Description
	from		partnertype
	order by	Description ASC

go

grant execute on [Admin_PartnerTypeGet] TO ExecuteOnlyRole

go

