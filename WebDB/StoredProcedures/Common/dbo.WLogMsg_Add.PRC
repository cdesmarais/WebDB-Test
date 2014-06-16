if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[WLogMsg_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[WLogMsg_Add]
GO


CREATE Procedure dbo.WLogMsg_Add
(
    /*Restaurant*/
	@Msg nvarchar(1000),
    @retVal int OUTPUT
)

As
SET NOCOUNT ON

SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION


BEGIN

	set @retVal = 0;

	-- Insert WLogMsg (if message exists)
	if (@Msg is not NULL and @Msg != '')
	begin
		insert into WLogMsgVW (Msg) values (@Msg)
		select @retVal = scope_identity()
	end

END


	COMMIT TRANSACTION

	Return(0)

GO


GRANT EXECUTE ON [WLogMsg_Add] TO ExecuteOnlyRole

GO
