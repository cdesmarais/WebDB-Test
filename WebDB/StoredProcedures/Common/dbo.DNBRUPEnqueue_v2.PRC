if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNBRUPEnqueue_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNBRUPEnqueue_v2]
GO


create procedure [dbo].[DNBRUPEnqueue_v2]
(
	 @RID			int
	,@BRUPMessage	image
	,@IsUmamiJSON	bit
	,@BatchID		int OUTPUT
)
AS

	SET NOCOUNT ON

	declare		 @error			int
				,@errorstr		nvarchar(100)


	-- INSERT binary message in BRUPQueue

	Insert into BRUPQueue
				(RID, BRUPMessage,CreateDt,IsUmamiJSON ) 
    values		(@RID, @BRUPMessage,getdate(),@IsUmamiJSON)

	set			 @error			= @@error
	set			@BatchID		= scope_identity()	-- return BatchID

	if @error != 0
	  begin
		set	 @errorstr = 'Failed to insert binary reso update batch in BRUPQueue.'
		RAISERROR(@errorstr,17,1)
		return (0)
	  end

GO

GRANT EXECUTE ON [DNBRUPEnqueue_v2] TO ExecuteOnlyRole

GO
