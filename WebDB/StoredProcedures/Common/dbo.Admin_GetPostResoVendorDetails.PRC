
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetPostResoVendorDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetPostResoVendorDetails]
go

create procedure [dbo].[Admin_GetPostResoVendorDetails]
(
	@languageid int
	,@Vendorid int
)
as
	select 
		VendorOrder
		,ImagePath
		,ImageLink
		,Title
		,Text
		,EmailText
		,EmailTag
	from
		PostResoVendorDetailLocal pl
		inner join PostResoVendorDetail p
		on pl.VendorID = p.VendorID
	where
		LanguageID = @languageid
		and pl.VendorID = @Vendorid
	
	select 
		VendorID
		,EmailTag
	from
		PostResoVendorDetail
	where 
		VendorID = @Vendorid 
go

GRANT EXECUTE ON [Admin_GetPostResoVendorDetails] TO ExecuteOnlyRole

go

