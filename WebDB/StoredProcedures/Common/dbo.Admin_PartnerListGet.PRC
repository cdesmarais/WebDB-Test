

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerListGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerListGet]
go

/*
	Get the list of all partners
*/

create procedure dbo.Admin_PartnerListGet
as

set nocount on
set transaction isolation level read uncommitted

select	PartnerID
		, PartnerName
		, pt.Description as PartnerType
		, ActiveFlag
		, reptype.ReportingSource as ReportingSourceType
		, ReportingDisplayName
from   partner p 
inner join partnerType pt
on p.PartnerTypeID = pt.PartnerTypeID

left outer join ReportingSourceType reptype
on reptype.ReportingSourceTypeID = p.ReportingSourceTypeId

order by ActiveFlag Desc, PartnerName ASC 

go

grant execute on [Admin_PartnerListGet] TO ExecuteOnlyRole

go

