
--Gets the list of the Hotels/Company
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CacheGetAllHotels]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CacheGetAllHotels]
go


create procedure dbo.CacheGetAllHotels
as  
set nocount on
set transaction isolation level read uncommitted  
  
select  
	comp.CompanyID as HotelID  
	,comp.CompanyName as HotelName
	,comp.Address1
	,comp.Address2
	,comp.City
	,comp.State
	,stat.StateName
	,comp.ZIP
	,cntry.CountryName
	,comp.Country  
	,comp.Phone
	,comp.FaxPhone
	,comp.EMail
	,comp.Logo
	,comp.OffProperty
	,comp.AcceptsPoints  
	,comp.metroareaid as metro_area_id  
	,mtro.metroareaname as Metro  
	,comp.isCharity as is_Charity 
	,comp.IsActive as Active 
	,comp.Notes
from  
	Company comp  

	inner join MetroAreaAVW mtro    
	on comp.metroareaid = mtro.metroareaid    

	inner join Domain dom  
	on mtro.SupportedDomainID = dom.domainID 
	
	left outer join StateName stat on 
	stat.StateID = comp.State
	
	left outer join CountryVW cntry on
	cntry.CountryID = comp.Country 

where
	comp.CompanyTypeID = 1 --company type is Hotel 
and
	dom.PrimaryLanguageID = mtro.languageID  
order by 
	comp.CompanyName asc  
  
go

grant execute on [CacheGetAllHotels] to ExecuteOnlyRole

GO