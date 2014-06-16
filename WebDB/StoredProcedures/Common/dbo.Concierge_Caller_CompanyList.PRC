if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_CompanyList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_CompanyList]
GO


CREATE PROCEDURE dbo.Concierge_Caller_CompanyList
 (
  @GeoID int,
  @CompanyTypeID int
 )
As
SET NOCOUNT ON

SELECT		co.CompanyID AS HotelID
			,co.CompanyName as HotelName
			,co.Phone
			,co.metroareaid as metro_area_id
			,m.metroareaname as Metro
			,co.isCharity as is_Charity
FROM		Company co
inner join	MetroAreaAVW m  
on			co.metroareaid = m.metroareaid  
inner join	Domain d
on			m.SupportedDomainID = d.domainID
WHERE		co.CompanyTypeID = @CompanyTypeID
and			d.PrimaryLanguageID = m.languageID
ORDER BY	co.CompanyName

if (@@ERROR <> 0)
	goto general_error

general_error:	
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Caller_CompanyList] TO ExecuteOnlyRole

GO
