if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SearchPerfLog_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SearchPerfLog_Add]
GO




CREATE Procedure dbo.SearchPerfLog_Add
(
    /*Restaurant*/
	@ServerIP	nvarchar(30),
	@MetroID	integer,
	@ProductID	integer,
	@StartTime	datetime,

	@Searches	integer,
	@Timeouts	integer,
	@NoConnects	integer,
	@Errors		integer,
	@Cuttoffs	integer,
	@NoAvails	integer,
	@TimesBack	integer

)

As
SET NOCOUNT ON

SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION


BEGIN


	-- Insert in SearchPerfLog
	INSERT INTO SearchPerfLog
	(
		ServerIP,
		MetroID,
		ProductID,
		StartTime,
		Searches,
		Timeouts,
		NoConnects,
		Errors,
		Cuttoffs,
		NoAvails,
		TimesBack
	)
	VALUES
	(
		@ServerIP,
		@MetroID,
		@ProductID,
		@StartTime,
		@Searches,
		@Timeouts,
		@NoConnects,
		@Errors,
		@Cuttoffs,
		@NoAvails,
		@TimesBack
	)

END

	if @@ERROR <> 0
		goto error

	COMMIT TRANSACTION

	Return(0)

error:
	ROLLBACK TRANSACTION
	RETURN('Failed to insert into SearchPerfLog:' + cast(@@ERROR as nvarchar))
GO


GRANT EXECUTE ON [SearchPerfLog_Add] TO ExecuteOnlyRole

GO
