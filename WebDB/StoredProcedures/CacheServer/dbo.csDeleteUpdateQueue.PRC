--$ create proc csDeleteUpdateQueue
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[csDeleteUpdateQueue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[csDeleteUpdateQueue]
go

create proc dbo.csDeleteUpdateQueue
(
	 @QueueIDs varchar(8000) --[List of Int IDs]
)
as
	set nocount on

	declare  @IDCount int
			,@DeleteCount int
	set @IDCount 		= 0
	set @DeleteCount 	= 0

	declare @IDTab table 
	(
		ID int
	)
	insert into @IDTab 
	(
		ID
	) (select distinct id from  dbo.fIDStrToTab(@QueueIDs, '|'))
	set @IDCount = @@rowcount

	delete 	CacheServerUpdateQueue
	where	ID in ( select ID from @IDTab )

	set @DeleteCount = @@rowcount

	select @IDCount 'IDCount', @DeleteCount 'DeleteCount'

	return 0
GO

GRANT EXECUTE ON [csDeleteUpdateQueue] to ExecuteOnlyRole

GO
