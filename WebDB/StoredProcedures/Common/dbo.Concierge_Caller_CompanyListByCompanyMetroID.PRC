

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_CompanyListByCompanyMetroID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_CompanyListByCompanyMetroID]
go


create procedure dbo.Concierge_Caller_CompanyListByCompanyMetroID
 (
  @GeoID int,
  @CompanyTypeID int,
  @CompanyMetroID int  
 )
as
set NOCOUNT on

	select		
		co.CompanyID as HotelID
		,co.CompanyName as HotelName
		,co.Phone
		,co.metroareaid as metro_area_id
		,m.metroareaname as Metro
		,co.isCharity as is_Charity

	from	
		Company co
		
	inner join	MetroAreaAVW m  
	on	co.MetroAreaID = m.metroareaid  
	
	inner join	Domain d
	on	m.SupportedDomainID = d.domainID

	where		
		co.CompanyTypeID = @CompanyTypeID
		and	d.PrimaryLanguageID = m.languageID
		and   co.MetroAreaID = @CompanyMetroID 
		
	order by 
		co.CompanyName

if (@@ERROR <> 0)
	goto general_error

general_error:	
	Return(0)
go

GRANT EXECUTE ON [Concierge_Caller_CompanyListByCompanyMetroID] TO ExecuteOnlyRole

go
