if exists (select * from dbo.sysobjects where ID = object_id(N'[dbo].[SFBRecordShareFeedback]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
drop procedure [dbo].[SFBRecordShareFeedback]
go

-- Records all the emails that a dff feedback was sent to.
-- If the dff can't be shared because the allowed sahre total is exceeded, return -1 
-- and set @TotalShared output param to the total times the email was previously shared.
-- Returns 0 on success and -1 on error.
create procedure dbo.SFBRecordShareFeedback
(
	 @ResID				int
	,@CustID			int				
	,@EmailAddressList	nvarchar(2500)	-- room for 30 comma seperated emails which can each be 75 chars	
	,@IsRegistered		bit				-- registered or anonymous
	,@TotalShared		int = 0 output	-- in case numallowed is exceeded, return # previously shared
	,@dbg				bit = 0			-- optional param for debugging only
)
as
	set nocount on
	set transaction isolation level read uncommitted 

	declare  @error				int
			,@rc				int
			,@ResIDExists		bit
			,@PrevCount			int
			,@CountNewAddresses	int
			,@NumAllowed		int

	-- Determine number of emails this user is allowed to send this dff to
	if @IsRegistered = 1 
		set @NumAllowed = 30 
	else 
		set @NumAllowed = 5

	/******************************************************************/
	if @dbg = 1 print '@NumAllowed = ' + cast( @NumAllowed as nvarchar )
	/******************************************************************/

	-- parse comma seperated list into a table
	declare @EmailAddressTable	table(
									 SFBEmail	nvarchar(75)
									,SFBEmailID	int	null
								)

	declare  @startPos			int
			,@endPos			int
			,@delim				nchar
			,@currentAddress	nvarchar(255) -- 255 is arbitrary, long enough for a invalidly long address
			,@length			int

	set @startPos = 0
	set @endPos = 0
	set @delim = ','

	if (charindex(@delim, @EmailAddressList,1) = 1) set @endPos = 1 

	--iterate through comma seperated list of email addresses
	--insert each address into a table
	while @endPos < len(@EmailAddressList)
	begin
		set @startPos = @endPos
		set @endPos = charindex(@delim, @EmailAddressList,@startPos+1)
		if (@endPos = 0)  set @endPos = len(@EmailAddressList) + 1
		
		set @currentaddress = ltrim(rtrim(substring(@EmailAddressList, @startPos + 1, @endpos - @startPos - 1)))
		set @length = len(@currentaddress)

		if (@endpos > @startPos + 1)
		begin
			-- note, if an email address is too long we just skip it.
			if ( @length > 0 and @length <= 75 )
			begin
				insert into @EmailAddressTable (SFBEmail) values (@currentaddress)
			end
		end
	end	

	/******************************************************************/
	if @dbg = 1	begin select * from @EmailAddressTable end
	/******************************************************************/

	-- fill in temp table with ids if they exist in the database already.
	update		t
	set			SFBEmailID		= sfbe.SFBEmailID
	from		@EmailAddressTable		t
	inner join	SFBEmailAddress			sfbe
	on			sfbe.SFBEmail	= t.SFBEmail COLLATE DATABASE_DEFAULT

	-- get count of new addresses the dff is being shared with
	select @CountNewAddresses = count(*) from @EmailAddressTable 

	/******************************************************************/
	if @dbg = 1	print '@CountNewAddresses: ' + cast ( @CountNewAddresses as nvarchar )
	/******************************************************************/

	-- check if this dff has been shared before
	select	@ResIDExists		= case when resid is null then 0 else 1 end
			,@PrevCount			= isnull(SendEmailCount, 0)
	from	SFBEmailCountByReso 
	where	resid				= @ResID 

	-- if resid doesn't exist, both values will be null	
	set @ResIDExists = isnull( @ResIDExists, 0 )
	set @PrevCount = isnull( @PrevCount, 0 )

	-- Check that the limit is not exceeded
	if @PrevCount + @CountNewAddresses > @NumAllowed or @CountNewAddresses = 0
	begin
		-- limit exceeded, don't send to anyone, and return number previously sent to
		set @TotalShared = @PrevCount
		goto ErrBlock
	end


	-- Begin updating the database...
	begin tran

		-- update or insert the SFBEmailCountByReso record with total count of email dff is sending to.
		if @ResIDExists = 1
		begin
			update	SFBEmailCountByReso
			set		SendEmailCount = @PrevCount + @CountNewAddresses
			where	ResID = @ResID
		end
		else
		begin
			insert SFBEmailCountByReso ( ResID, SendEmailCount ) values ( @ResID, @CountNewAddresses )
		end

		-- insert new email addresses that weren't previously in the  database 
		insert	SFBEmailAddress (SFBEmail)
		select	distinct SFBEmail			-- make sure to use distinct in case a new address was entered twice
		from	@EmailAddressTable	t
		where	t.SFBEmailID is null

		select @error = @@error
		if @error != 0 goto TranErrBlock

		-- fill in temp table with ids of newly inserted records
		update		t
		set			SFBEmailID		= sfbe.SFBEmailID
		from		@EmailAddressTable		t
		inner join	SFBEmailAddress			sfbe
		on			sfbe.SFBEmail			= t.SFBEmail COLLATE DATABASE_DEFAULT
		where		t.SFBEmailID	is null

		select @error = @@error
		if @error != 0 goto TranErrBlock

		-- map the new emails to the current user
		insert	SFBEmailAddressToCust (CustID, SFBEmailID)
		select	distinct @CustID					-- make sure to use distinct in case a new address was entered twice
						,t.SFBEmailID
		from			@EmailAddressTable	t
		left join		SFBEmailAddressToCust  ea2c
		on				ea2c.SFBEmailID = t.SFBEmailID
		and				ea2c.CustID = @CustID
		where			ea2c.CustID is null				-- don't insert if already there

		select @error = @@error
		if @error != 0 goto TranErrBlock

	commit tran
	

	return 0

TranErrBlock:
	rollback tran

ErrBlock:
	return -1

go


grant execute on [SFBRecordShareFeedback] to ExecuteOnlyRole
go
