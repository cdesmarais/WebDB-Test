
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ConciergeCompany_SearchByUserLastName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ConciergeCompany_SearchByUserLastName]
GO


CREATE PROCEDURE dbo.Admin_ConciergeCompany_SearchByUserLastName
 (
  @UserLastName	nvarchar (40)
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT	DISTINCT
	co.CompanyID AS HotelID
	,co.CompanyName as HotelName
	,co.Phone as HotelPhone
	,ca.CallerStatusID as Active
FROM
	Company co

inner join	MetroAreaAVW m  
on	co.metroareaid = m.metroareaid  

inner join	Domain d
on	m.SupportedDomainID = d.domainID

inner join  Caller ca
on	ca.CompanyID = co.CompanyID

WHERE
	co.CompanyTypeID = 1 and
	d.PrimaryLanguageID = m.languageID and
	ca.LName LIKE '%' + @UserLastName + '%'
ORDER BY
	co.CompanyName

if (@@ERROR <> 0)
	goto general_error

general_error:	
	Return(0)
GO

GRANT EXECUTE ON [Admin_ConciergeCompany_SearchByUserLastName] TO ExecuteOnlyRole

GO
