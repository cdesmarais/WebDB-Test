if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroUpdateBase]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroUpdateBase]
GO

create procedure dbo.Admin_MetroUpdateBase
(
  @name nvarchar(255),
  @searchlevel int,
  @emailcontact nvarchar(255),
  @message nvarchar(999),
  @active bit,
  @ID int,
  @TopTenList bit,
  @Tzid int,
  @CountryID nvarchar(2),
  @TitleTag nvarchar(255),
  @DFFStartDT nvarchar(255),
  @MinNumRests int,
  @DisplayDays int,
  @ShortDisplayName nvarchar(50),
  @MetaDescriptionText nvarchar(255),
  @MetaKeywordText nvarchar(255),
  @LookupIDs nvarchar(255)
)
AS

BEGIN TRANSACTION

if @DFFStartDT = ''
begin
	Set @DFFStartDT = null
end


declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @dbstartdt datetime


set @ProcName = 'Admin_MetroUpdateBase'

select	@dbstartdt = dffstartdt from metroareavw where metroareaid = @ID

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
	Active=@active,
	SearchLevel=@searchlevel,
	EmailContact=@emailcontact,
	Tzid=@Tzid,
	CountryID=@CountryID,
	DFFStartDT=@DFFStartDT,
	MinNumRests=@MinNumRests,
	DisplayDays=@DisplayDays
	 
where 
	metroareaid=@ID  

set @DBError = @@error
if @DBError <> 0
	goto general_error

--**********************
--** Update Local Table
--**********************
set @Action = 'UPDATE MetroAreaLocal'
update 
	MetroAreaLocal  
set
	MetroAreaName=@name,
	Message=@message,
	TitleTag=@TitleTag,
	ShortDisplayName=@ShortDisplayName,
	MetaDescriptionText = @MetaDescriptionText,
	MetaKeywordText = @MetaKeywordText
where 
	metroareaid = @ID  
and		LanguageID = @LanguageID


--***********************************************  
--** Update Timezone for All restaurants in Metro
--***********************************************  
update 
	restaurant 
SET 
	TZID = m.tzid
from 	
	restaurant r
inner join neighborhood n 
on 	r.neighborhoodid = n.neighborhoodID
inner join metroarea m 
on 	n.metroareaid = m.metroareaid
where
	m.metroareaID = @ID and r.TZID != m.tzid



set @DBError = @@error
if @DBError <> 0
	goto general_error


	
--**********************
--** Update Lookup IDs
--**********************		

-- Delete AUTOFILL_METRO_WHITELIST, REDENVELOPE_METRO_EXCLUDE, MOBILE_INFO_METRO_BLACKLIST
Delete from ValueLookupIDList where ValueID = @ID and LookupID in (4,6,10)

INSERT INTO [ValueLookupIDList] (
	[LookupID],
	[ValueID]
)
select id, @ID from fIDStrToTab(@LookupIDs, ',')

set @DBError = @@error
if @DBError <> 0
	goto general_error

	
	
COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)




GO

GRANT EXECUTE ON [Admin_MetroUpdateBase] TO ExecuteOnlyRole

GO
