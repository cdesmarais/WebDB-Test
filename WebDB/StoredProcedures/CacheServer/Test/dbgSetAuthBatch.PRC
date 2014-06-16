--$ create proc dbgSetAuthBatch
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dbgSetAuthBatch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[dbgSetAuthBatch]
go

create proc dbgSetAuthBatch
(
	@RIDBegin int
	,@RIDEnd int
	,@MAC nvarchar(64)
	,@NextMac nvarchar(64)
)
as
begin
	set nocount on

	update ERBRestaurant
	set NetworkAddress = @MAC, NewNetworkAddress = @NextMac
	where RID between @RIDBegin and @RIDEnd

	declare @i int
	set @i = @RIDBegin
	while @i <= @RIDEnd
	begin
		insert into CSRestUpdates(RID, UpdateDateTS) values (@i, current_timestamp)
		set @i = @i + 1	
	end
end
go



