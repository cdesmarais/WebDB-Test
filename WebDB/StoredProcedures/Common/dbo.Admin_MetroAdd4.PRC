if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroAdd4]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroAdd4]
GO

create procedure dbo.Admin_MetroAdd4
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
	,@MetroTitleTag nvarchar(126)
	,@DomainID int
	,@MetaDescriptionText nvarchar(255)
	,@MetaKeywordText nvarchar(255)
	,@LookupIDs nvarchar(255)
	,@ShowRegionLists BIT
	,@ShowSpotlight BIT
	,@SpotLightLink NVARCHAR(255)
	,@SpotlightLinkText NVARCHAR(80)
	,@SpotLightImage NVARCHAR(255)
	,@retval int =1 OUTPUT
)
as

begin transaction

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @ID int

set @ProcName = 'Admin_MetroAdd4'

if (@sname is null)
	set @sname = ''

if (@DFFStartDT = '')
	set @DffStartDT = null
	
--**********************
--** Get Language
--**********************
set @Action = 'Retrieve LanguageID'
declare @LanguageID int

Select 
	@LanguageID =PrimaryLanguageID 
from 
	[Domain]
where 
	DomainID = @DomainID

set @DBError = @@error
if @DBError <> 0
	goto general_error

--**********************
--** Insert into Master Table
--**********************
set @Action = 'INSERT INTO MetroArea'
	
insert into MetroArea  
(
	Active
	,SearchLevel
	,EmailContact
	,TopTenList
	,Tzid
	,CountryID
	,DFFStartDT
	,MinNumRests
	,DisplayDays
	,OpLanguageID
	,SupportedDomainID
	,ShowRegionLists
	,DFFChangeActionDTUTC	
	,ShowSpotlight
)
values  
(
	@active
	,@searchlevel
	,@emailcontact
	,@TopTenList
	,@Tzid
	,@CountryID
	,@DFFStartDT
	,@MinNumRests
	,@DisplayDays
	,@LanguageID
	,@DomainID
	,@ShowRegionLists
	,getutcdate()
	,@ShowSpotlight
)

set @DBError = @@error
if @DBError <> 0
	goto general_error

set @ID = scope_identity()
set @retval=@ID
  
--**********************
--** Insert into Local Table
--**********************
set @Action = 'INSERT INTO MetroAreaLocal'

insert into MetroAreaLocal
(
	MetroAreaID
	,LanguageID
	,MetroAreaName
	,Message
	,TitleTag
	,ShortDisplayName
	,MetroTitleTag
	,MetroAreaSName
	,MetaKeywordText
	,MetaDescriptionText
	,SpotlightLink
	,SpotlightLinkText
	,SpotlightImage
)
values
(
	@ID
	,@LanguageID
	,@name
	,@message
	,@TitleTag
	,@ShortDisplayName
	,@MetroTitleTag
	,@sname
	,@MetaKeywordText
	,@MetaDescriptionText
	,@SpotlightLink
	,@SpotlightLinkText
	,@SpotlightImage
)

set @DBError = @@error
if @DBError <> 0
	goto general_error

--**********************
--** Add Lookup IDs
--**********************		

insert into [ValueLookupIDList] 
(
	[LookupID]
	,[ValueID]
)
select 
	id
	,@ID 
from 
	fIDStrToTab(@LookupIDs, ',')

set @DBError = @@error
if @DBError <> 0
	goto general_error


commit transaction
return(0)

general_error:
	rollback transaction
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	return(0)

GO

GRANT EXECUTE ON [Admin_MetroAdd4] TO ExecuteOnlyRole
GO  


