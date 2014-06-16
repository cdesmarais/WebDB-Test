if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNBRUPEnqueue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNBRUPEnqueue]
GO


create procedure [dbo].[DNBRUPEnqueue]
(
	 @RID			int
	,@BRUPMessage	image
	,@BatchID		int OUTPUT
)
AS

	SET NOCOUNT ON

	declare		 @error			int
				,@errorstr		nvarchar(100)


	-- INSERT binary message in BRUPQueue

	Insert into BRUPQueue
				(RID, BRUPMessage,CreateDt) 
    values		(@RID, @BRUPMessage,getdate())

	set			 @error			= @@error
	set			@BatchID		= scope_identity()	-- return BatchID

	if @error != 0
	  begin
		set	 @errorstr = 'Failed to insert binary reso update batch in BRUPQueue.'
		RAISERROR(@errorstr,17,1)
		return (0)
	  end

GO

GRANT EXECUTE ON [DNBRUPEnqueue] TO ExecuteOnlyRole

GO
