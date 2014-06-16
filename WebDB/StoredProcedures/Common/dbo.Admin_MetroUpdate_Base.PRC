

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroUpdate_Base]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroUpdate_Base]
GO

create procedure dbo.Admin_MetroUpdate_Base
(
	@name nvarchar(255)
	,@sname nvarchar(255)
	,@searchlevel int
	,@emailcontact nvarchar(255)
	,@message nvarchar(999)
	,@active bit
	,@ID int
	,@TopTenList bit
	,@Tzid int
	,@CountryID nvarchar(2)
	,@TitleTag nvarchar(255)
	,@DFFStartDT nvarchar(255)
	,@MinNumRests int
	,@DisplayDays int
	,@ShortDisplayName nvarchar(50)
	,@MetaDescriptionText nvarchar(255)
	,@MetaKeywordText nvarchar(255)
	,@LookupIDs nvarchar(255)
)
as


exec Admin_MetroUpdate_Base2 
	 @name
	,@sname
	,@searchlevel
	,@emailcontact
	,@message
	,@active
	,@ID
	,@TopTenList
	,@Tzid
	,@CountryID
	,@TitleTag
	,@DFFStartDT
	,@MinNumRests
	,@DisplayDays
	,@ShortDisplayName
	,@MetaDescriptionText 
	,@MetaKeywordText 
	,@LookupIDs 
	,0 -- ShowRegionLists

GO

GRANT EXECUTE ON [Admin_MetroUpdate_Base] TO ExecuteOnlyRole

GO


