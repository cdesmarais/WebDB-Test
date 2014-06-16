if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[WLog_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[WLog_Add]
GO

CREATE Procedure dbo.WLog_Add
(
    /*Restaurant*/
	@WLogType	int, 
	@FuncEntryPt	nvarchar(100), 
	@Status		int,
	@Error		int,
	@ElapsedMS	int,
	@RID		int,
	@ConfNumber	varchar(20), -- EV: This value represents a number and will be converted to an int as part of the insert
	@CustID		int,
	@CallerID	int,
	@IPServer	nvarchar(20),
	@IPErb		nvarchar(20),
	@InWLogMsg nvarchar(1000),
	@OutWLogMsg nvarchar(1000),
	@createDT   datetime = null
)

As
SET NOCOUNT ON

SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION


--Special handling for conf number; if it was passed as an empty string then treat it as null
if (@ConfNumber	= '') set @ConfNumber = null

BEGIN

	declare @InWLogMsgID as int
	declare @OutWLogMsgID as int

	set @InWLogMsgID = 0
	set @OutWLogMsgID = 0

	-- Insert WLogMsg (if message exists)
	if (@InWLogMsg is not NULL and @InWLogMsg != '')
	begin
		insert into WLogMsgVW (Msg) values (@InWLogMsg)
		select @InWLogMsgID = scope_identity()
	end

	if (@OutWLogMsg is not NULL and @OutWLogMsg != '')
	begin
		insert into WLogMsgVW (Msg) values (@OutWLogMsg)
		select @OutWLogMsgID = scope_identity()
	end

	-- Check if Type exists in type table; if not set type to -1
	declare @TypeExists as int
	select @TypeExists = count(*) from WLogTypeVW where WLogType = @WLogType
	if (@TypeExists = 0)
		set @WLogType = -1

	-- force empty string to null for confnumber
	if (@ConfNumber = '') set @ConfNumber = null

-- Insert in WLog
	INSERT INTO WLogVW
	(
		WLogType,
		FuncEntryPt,
		Status,
		Error,
		ElapsedMS,
		RID,
		ConfNumber,
		CustID,
		CallerID,
		IPServer,
		IPErb,
		InWLogMsgID,
		OutWLogMsgID,
		createdt
	)
	VALUES
	(
		@WLogType,
		@FuncEntryPt,
		@Status,
		@Error,
		@ElapsedMS,
		@RID,
		@ConfNumber,
		@CustID,
		@CallerID,
		@IPServer,
		@IPErb,
		@InWLogMsgID,
		@OutWLogMsgID,
		coalesce(@createDT ,getdate())
	)

END

	if @@ERROR <> 0
		goto error

	COMMIT TRANSACTION

	Return(0)

error:
	ROLLBACK TRANSACTION
	RETURN(0)


GO



GRANT EXECUTE ON [WLog_Add] TO ExecuteOnlyRole

GO
