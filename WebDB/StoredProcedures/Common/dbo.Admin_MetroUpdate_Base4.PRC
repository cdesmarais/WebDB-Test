if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroUpdate_Base4]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroUpdate_Base4]
GO

create procedure dbo.Admin_MetroUpdate_Base4
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
	,@ShowRegionLists bit  
	,@MetroTitleTag nvarchar(150)
	,@ShowSpotlight bit  
	,@SpotlightLink nvarchar(255)
	,@SpotlightLinkText nvarchar(80)
	,@SpotlightImage nvarchar(255)
)
as

begin transaction

if (@sname is null)
	set @sname = ''

if @DFFStartDT = ''
begin
	Set @DFFStartDT = null
end

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @CurrentStartDT datetime
declare @CurrentDFFChangeActionDT datetime  
declare @NewDFFStartDT varchar(10)  
declare @CurrentDFFStartDT varchar(10)  
declare @NewDFFDT datetime  
declare @UpdateCount int  

set @ProcName = 'Admin_MetroUpdate_Base2'

-- strore current DFF Start date and Change Action Date in local variable
select	
	@CurrentStartDT = dffstartdt
	,@CurrentDFFChangeActionDT = DFFChangeActionDTUTC
from 
	metroareavw
where 
	metroareaid = @ID


--**********************
--** Get Language
--**********************
set @Action = 'Retrieve LanguageID'
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID
set @DBError = @@error
if @DBError <> 0
	goto general_error

--**********************
--** Update Master TAble
--**********************
set @Action = 'UPDATE MetroArea'

update 
	MetroArea  
set
	Active=@active
	,SearchLevel=@searchlevel
	,EmailContact=@emailcontact
	,Tzid=@Tzid
	,CountryID=@CountryID
	,DFFStartDT=@DFFStartDT
	,MinNumRests=@MinNumRests
	,DisplayDays=@DisplayDays
	,ShowRegionLists=@ShowRegionLists
	,ShowSpotlight=@ShowSpotlight
where 
	metroareaid=@ID  

set @UpdateCount = @@rowcount  

set @DBError = @@error
if @DBError <> 0
	goto general_error

--*************************************************************************    
--If DFF Start Date has been updated then  
-- 1. Update DFF Change Action Date in MetroArea table  
-- 2. Insert last status of DFF Start date into DFFDateActivityLog table  
--*************************************************************************    
  
-- Upate record only if updatecount is greater than 0  
if @UpdateCount > 0   
begin  
  
	set @NewDFFDT = cast (@DFFStartDT as datetime)  
	set @NewDFFStartDT = coalesce(convert(VARCHAR(10), @NewDFFDT,101),'')  
	set @CurrentDFFStartDT   = coalesce(convert(VARCHAR(10), @CurrentStartDT,101),'')   
  
	if @NewDFFStartDT <> @CurrentDFFStartDT  
	begin    
     
		update     
			MetroArea      
		set    
			DFFChangeActionDTUTC = getutcdate()    
		where     
			metroareaid=@ID      
		--Insert last status of DFF Start date into DFFDateActivityLog table  
		exec Admin_LogDFFDateActivity @ID,@CurrentStartDT,@CurrentDFFChangeActionDT    
   end    
  
	set @DBError = @@error  
	if @DBError <> 0  
		goto general_error  
end  

--**********************
--** Update Local Table
--**********************
set @Action = 'UPDATE MetroAreaLocal'
update 
	MetroAreaLocal  
set
	MetroAreaName=@name
	,Message=@message
	,TitleTag=@TitleTag
	,ShortDisplayName=@ShortDisplayName
	,MetroAreaSName=@sname
	,MetaKeywordText=@MetaKeywordText
	,MetaDescriptionText=@MetaDescriptionText
	,MetroTitleTag=@MetroTitleTag
	,SpotlightLink=@SpotlightLink
	,SpotlightLinkText=@SpotlightLinkText
	,SpotlightImage=@SpotlightImage
where 
	metroareaid = @ID and
	LanguageID = @LanguageID

--***********************************************  
--** Update Timezone for All restaurants in Metro
--***********************************************  
update 
	restaurant 
SET 
	TZID = m.tzid
from 	
	restaurant r
	inner join neighborhood n on
 	r.neighborhoodid = n.neighborhoodID
	
	inner join metroarea m on
 	n.metroareaid = m.metroareaid

where
	m.metroareaID = @ID and
	r.TZID != m.tzid

set @DBError = @@error
if @DBError <> 0
	goto general_error

--**********************
--** Update Lookup IDs
--**********************		

-- Delete AUTOFILL_METRO_WHITELIST, REDENVELOPE_METRO_EXCLUDE, MOBILE_INFO_METRO_BLACKLIST, MAPSEARCH_METRO_BLACKLIST, RATINGS_REVIEWS_UI_METRO_BLACKLIST
delete from
	ValueLookupIDList 
where
	ValueID = @ID and
	LookupID in (4,6,10,19,20,34)

insert into[ValueLookupIDList] 
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
Return(0)

general_error:
	rollback transaction
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	return(0)

GO

GRANT EXECUTE ON [Admin_MetroUpdate_Base4] TO ExecuteOnlyRole

GO


