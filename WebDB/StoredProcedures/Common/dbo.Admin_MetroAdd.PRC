if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroAdd]
GO

create procedure dbo.Admin_MetroAdd
(
	@name nvarchar(255)
	,@sname nvarchar(255)
	,@searchlevel int
	,@emailcontact nvarchar(255)
	,@message nvarchar(999)
	,@active bit
	,@TopTenList bit
	,@Tzid int
	,@CountryID nvarchar(2)
	,@TitleTag nvarchar(255)
	,@DFFStartDT datetime
	,@MinNumRests int
	,@DisplayDays int
	,@ShortDisplayName nvarchar(50)
	,@DomainID int
	,@MetaDescriptionText nvarchar(255)
	,@MetaKeywordText nvarchar(255)
	,@LookupIDs nvarchar(255)
	,@retval int =1 OUTPUT
)
as


exec Admin_MetroAdd2 @name,@sname,@searchlevel,@emailcontact,@message,@active,@TopTenList,@Tzid,@CountryID,@TitleTag,@DFFStartDT,@MinNumRests
	,@DisplayDays,@ShortDisplayName,@DomainID,@MetaDescriptionText,@MetaKeywordText,@LookupIDs,0,@retval

GO
	
GRANT EXECUTE ON [Admin_MetroAdd] TO ExecuteOnlyRole

GO  


