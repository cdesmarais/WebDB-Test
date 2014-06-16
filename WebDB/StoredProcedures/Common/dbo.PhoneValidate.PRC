if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PhoneValidate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PhoneValidate]
GO

CREATE Procedure dbo.PhoneValidate
(
    /*Restaurant*/
    @Phone nvarchar(255),
	@CountryID char(2),
	@canBeNull int,
	@retval nvarchar(24) OUTPUT
)

As
SET NOCOUNT ON

declare @FormatedPhone nvarchar(43)
declare @CleanPhone nvarchar(43)
declare @PhoneBase nvarchar(43)
declare @FormatID int
declare @extIndex int

if (@Phone is null or @Phone='')
begin
	if (@canBeNull = 0)
		RAISERROR('Phone number cannot be empty',16,1)
	return
end

set @FormatedPhone = dbo.fCleanPhone(@Phone,1)

set @extIndex = charindex('x',@FormatedPhone)

if (@extIndex > 0)
begin
	set @PhoneBase = substring(@FormatedPhone, 1, @extIndex - 1)

	-- check if multiple x's / illegal
	set @extIndex = charindex('x',@FormatedPhone, @extIndex+1)
	if (@extIndex > 0)
	begin
		RAISERROR('x can not be used as a phone seperator: %s',16,1, @Phone)
	end
end
else
begin
	set @PhoneBase = @FormatedPhone
end

select @FormatID = PhoneFormatID from phoneformat
where PhoneMatchCode = @PhoneBase
and CountryID = @CountryID

set @CleanPhone = dbo.fCleanPhone(@Phone,0)
if (@FormatID is null)
	set @CleanPhone = replace(@CleanPhone,'.','')

set @extIndex = charindex('x',@CleanPhone) - 1
if @extIndex < 1
	set @extIndex = len(@CleanPhone)


declare @numLen int
set @numLen = len(replace(substring(@CleanPhone,1, @extIndex),'.',''))

if (@numLen > 15 or @numLen < 1)
begin
	RAISERROR ('Invalid Phone Length: %s len: %d',16,1, @Phone, @numLen)
end
else if (@CountryID = 'UK' and @numLen != 11)
begin
	RAISERROR ('Invalid UK Phone Length: %s len: %d',16,1, @Phone, @numLen)
end
else if ((@CountryID = 'US' or @CountryID = 'US') and @numLen != 10)
begin
	RAISERROR ('Invalid US Phone Length: %s len: %d',16,1, @Phone, @numLen)
end

	set @retval =  @CleanPhone
go

GRANT EXECUTE ON [PhoneValidate] TO ExecuteOnlyRole

GO
