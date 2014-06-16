
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_InsertUpdate_VendorDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_InsertUpdate_VendorDetails]
go


create procedure [dbo].[Admin_InsertUpdate_VendorDetails]
(
	@resoconfirmationmessage nvarchar(1000)
	,@languageid int
	,@Vendorid int
	,@Vendororder int
	,@imgpath varchar(1000)
	,@imglink varchar(1000)
	,@title nvarchar(100)
	,@text nvarchar(1600)
	,@emailText nvarchar(1000)
)
as

if not exists(select 1 from PostResoVendorlocal where LanguageID = @languageid)
	begin
		insert 
			into PostResoVendorlocal
			(GreenBoxText
			,PostResoVendorID
			,LanguageID)
			values
			(@resoconfirmationmessage
			,1
			,@languageid)
	end
else
	begin
		update 
			PostResoVendorlocal
		set 
			GreenBoxText = @resoconfirmationmessage
		where 
			LanguageID = @languageid
	end
	
if not exists(select 1 from PostResoVendorDetailLocal where VendorID = @Vendorid and LanguageID = @languageid)
	begin
		insert into
			PostResoVendorDetailLocal
			(VendorID
			,LanguageID
			,VendorOrder
			,ImagePath
			,ImageLink
			,Title
			,Text
			,EmailText)
			values
			(@Vendorid
			,@languageid
			,@Vendororder
			,@imgpath
			,@imglink
			,@title
			,@text
			,@emailText)
	end
else
	begin
		update
			PostResoVendorDetailLocal
		set
			VendorOrder = @Vendororder
			,ImagePath = @imgpath
			,ImageLink = @imglink
			,Title = @title
			,Text = @text
			,EmailText = @emailText
		where
			VendorID = @Vendorid
			and LanguageID = @languageid
	end
go

GRANT EXECUTE ON [Admin_InsertUpdate_VendorDetails] TO ExecuteOnlyRole

go

