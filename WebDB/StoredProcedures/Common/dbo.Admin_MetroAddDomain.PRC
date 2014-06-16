if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroAddDomain]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroAddDomain]
GO

create procedure dbo.Admin_MetroAddDomain  
(
  @name nvarchar(255),
  @searchlevel int,
  @emailcontact nvarchar(255),
  @message nvarchar(999),
  @active bit,
  @TopTenList bit,
  @Tzid int,
  @CountryID nvarchar(2),
  @TitleTag nvarchar(255),
  @DFFStartDT datetime,
  @MinNumRests int,
  @DisplayDays int,
  @ShortDisplayName nvarchar(50),
  @DomainID int,
  @MetaDescriptionText nvarchar(255),
  @MetaKeywordText nvarchar(255),
  @LookupIDs nvarchar(255),
  @retval int =1 OUTPUT
)
AS

BEGIN TRANSACTION

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @ID int

set @ProcName = 'Admin_MetroAddDomain'

if (@DFFStartDT = '')
	set @DffStartDT = null
	
--**********************
--** Get Language
--**********************
set @Action = 'Retrieve LanguageID'
declare @LanguageID int

Select @LanguageID =PrimaryLanguageID from [Domain] where DomainID = @DomainID

set @DBError = @@error
if @DBError <> 0
	goto general_error

--**********************
--** Insert into Master Table
--**********************
set @Action = 'INSERT INTO MetroArea'
	
insert into MetroArea  
(
	Active,
	SearchLevel,
	EmailContact,
	TopTenList,
	Tzid,
	CountryID,
	DFFStartDT,
	MinNumRests,
	DisplayDays,
	OpLanguageID,
	SupportedDomainID
)
values  
(
	@active,
	@searchlevel,
	@emailcontact,
	@TopTenList,
	@Tzid,
	@CountryID,
	@DFFStartDT,
	@MinNumRests,
	@DisplayDays,
	@LanguageID,
	@DomainID
)
set @DBError = @@error
if @DBError <> 0
	goto general_error

set @ID=scope_identity()
set @retval=@ID

--**********************
--** Insert into Local Table
--**********************
set @Action = 'INSERT INTO MetroAreaLocal'

insert into MetroAreaLocal
(
	MetroAreaID,
	LanguageID,
	MetroAreaName,
	Message,
	TitleTag,
	ShortDisplayName,
	MetaDescriptionText,
	MetaKeywordText
)
values
(
	@ID,
	@LanguageID,
	@name,
	@message,
	@TitleTag,
	@ShortDisplayName,
	@MetaDescriptionText,
	@MetaKeywordText
)
set @DBError = @@error
if @DBError <> 0
	goto general_error


	
--**********************
--** Add Lookup IDs
--**********************		

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

GRANT EXECUTE ON [Admin_MetroAddDomain] TO ExecuteOnlyRole
GO  


