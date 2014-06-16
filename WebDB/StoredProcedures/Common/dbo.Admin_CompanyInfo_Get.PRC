
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CompanyInfo_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CompanyInfo_Get]
GO


create procedure dbo.Admin_CompanyInfo_Get
  (
  @Company_ID int
 )
as
set nocount on
set transaction isolation level read uncommitted

select 
	cmp.CompanyName as Name
	,cmp.Address1 as Address
	,cmp.Address2
	,cmp.City
	,cmp.State
	,cmp.Zip as Postal_Code
	,cmp.Notes
	,cmp.EMail
	,cmp.metroareaid as Metro_Area_ID
	,cmp.CompanyTypeID as Company_Type_ID
	,cmp.CompanyGroupID as Company_Group_ID
	,cmp.Phone
	,cmp.FaxPhone as Fax_Phone
	,cmp.Logo
	,cmp.AcceptsPoints as accepts_points
	,cmp.OffProperty as OffProperty
	,cmp.Country as Country
	,coalesce(sn.StateName, cmp.state) as StateName
	,cntry.CountryName
from 
	Company cmp
	left outer join StateName sn on 
	sn.StateID = cmp.State
	
	left outer join CountryVW cntry on
	cntry.CountryID = cmp.Country

where 
	CompanyID = @Company_ID


go

GRANT EXECUTE ON [Admin_CompanyInfo_Get] TO ExecuteOnlyRole

GO
