
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ConciergeCompany_SearchByPhone]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ConciergeCompany_SearchByPhone]
GO


create procedure dbo.Admin_ConciergeCompany_SearchByPhone
(
	@CompPhone	varchar (24)
)
as
set nocount on
set transaction isolation level read uncommitted

select 
	 co.CompanyID as HotelID
	,co.CompanyName as HotelName
	,co.Phone as HotelPhone
	,co.IsActive as Active
from
	Company co

inner join	MetroAreaAVW m  
on	co.metroareaid = m.metroareaid  

inner join	Domain d
on	m.SupportedDomainID = d.domainID

where
	co.CompanyTypeID = 1 and
	d.PrimaryLanguageID = m.languageID and
	co.Phone LIKE '%' + @CompPhone + '%'
ORDER BY
	co.CompanyName

if (@@ERROR <> 0)
	goto general_error

general_error:	
	Return(0)
go

grant execute on [Admin_ConciergeCompany_SearchByPhone] to ExecuteOnlyRole

go
