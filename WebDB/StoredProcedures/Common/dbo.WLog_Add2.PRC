if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[WLog_Add2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[WLog_Add2]
GO

CREATE Procedure dbo.WLog_Add2
(
    /*Restaurant*/
	@WLogType	int, 
	@FuncEntryPt	nvarchar(100), 
	@Status		int,
	@Error		int,
	@ElapsedMS	int,
	@RID		int,
	@ConfNumber	nvarchar(20),
	@CustID		int,
	@CallerID	int,
	@IPServer	nvarchar(20),
	@IPErb		nvarchar(20),
	@InWLogMsgID int,
	@OutWLogMsgID int
)
--**************************************************
--** Procedure is very similar to WLogAdd
--** Except this procedure assumes msgs have already been created
--**************************************************
As
SET NOCOUNT ON

SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION

--Special handling for conf number; if it was passed as an empty string then treat it as null
if (@ConfNumber	= '') set @ConfNumber = null


BEGIN

	-- Check if Type exists in type table; if not set type to -1
	declare @TypeExists as int
	select @TypeExists = count(*) from WLogTypeVW where WLogType = @WLogType
	if (@TypeExists = 0)
		set @WLogType = -1


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
		OutWLogMsgID
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
		@OutWLogMsgID
	)
	if @@ERROR <> 0
		goto error

END

	if @@ERROR <> 0
		goto error

	COMMIT TRANSACTION

	Return(0)

error:
	ROLLBACK TRANSACTION
	RETURN(0)


GO


GRANT EXECUTE ON [WLog_Add2] TO ExecuteOnlyRole

GO
