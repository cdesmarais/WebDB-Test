
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ConciergeCompany_SearchByCompanyName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ConciergeCompany_SearchByCompanyName]
GO


CREATE PROCEDURE dbo.Admin_ConciergeCompany_SearchByCompanyName
 (
  @CompanyName nvarchar (60)
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT		
	co.CompanyID AS HotelID
	,co.CompanyName as HotelName
	,co.Phone as HotelPhone
	,co.IsActive as Active
FROM
	Company co

inner join	MetroAreaAVW m  
on	co.metroareaid = m.metroareaid  

inner join	Domain d
on	m.SupportedDomainID = d.domainID

WHERE
	co.CompanyTypeID = 1 and
	d.PrimaryLanguageID = m.languageID and
	co.CompanyName like '%' + @CompanyName + '%'
ORDER BY
	co.CompanyName

if (@@ERROR <> 0)
	goto general_error

general_error:	
	Return(0)
GO

GRANT EXECUTE ON [Admin_ConciergeCompany_SearchByCompanyName] TO ExecuteOnlyRole

GO
