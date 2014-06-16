
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ConciergeCompany_SearchByAddress]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ConciergeCompany_SearchByAddress]
GO


create procedure dbo.Admin_ConciergeCompany_SearchByAddress
(
	@CompAdd nvarchar (256)
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

inner join CountryLocal c
on c.CountryID = co.Country

inner join StateName s
on s.StateID = co.State

where
	co.CompanyTypeID = 1 
	and d.PrimaryLanguageID = m.languageID 
	and c.LanguageID = m.languageID 
	and(co.Address1 LIKE '%' + @CompAdd + '%' 
	or co.Address2 LIKE '%' + @CompAdd + '%'
	or co.City LIKE '%' + @CompAdd + '%'
	or co.ZIP LIKE '%' + @CompAdd + '%'
	or c.CountryName LIKE '%' + @CompAdd + '%'
	or co.Country LIKE '%' + @CompAdd + '%'
	or s.StateName LIKE '%' + @CompAdd + '%'
	or co.State LIKE '%' + @CompAdd + '%')
ORDER BY
	co.CompanyName

if (@@ERROR <> 0)
	goto general_error

general_error:	
	Return(0)
go

grant execute on [Admin_ConciergeCompany_SearchByAddress] to ExecuteOnlyRole

go
