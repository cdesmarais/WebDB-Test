
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetResoConfirmationDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetResoConfirmationDetails]
go


create procedure [dbo].[Admin_GetResoConfirmationDetails]
(
	@languageid int
)
as
	select 
		GreenBoxText
	from
		PostResoVendorLocal
	where
		LanguageID = @languageid
		and PostResoVendorID = 1

go

GRANT EXECUTE ON [Admin_GetResoConfirmationDetails] TO ExecuteOnlyRole

go

