if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_WebServiceTierGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_WebServiceTierGet]
go

create procedure dbo.Admin_WebServiceTierGet
as

set nocount on
set transaction isolation level read uncommitted
  
select		WebServiceTierID, 
			WebServiceTierDescription
from		WebServiceTier
order by	WebServiceTierDescription ASC

go

grant execute on [Admin_WebServiceTierGet] TO ExecuteOnlyRole

go

