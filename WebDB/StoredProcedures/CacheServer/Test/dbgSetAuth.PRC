--$ create proc dbgSetAuth
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[dbgSetAuth]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[dbgSetAuth]
go
create proc dbgSetAuth
(
	@RID int
	,@MAC nvarchar(64)
	,@NextMac nvarchar(64)
)
as
begin
	set nocount on

	update ERBRestaurant
	set NetworkAddress = @MAC, NewNetworkAddress = @NextMac
	where RID = @RID

	insert into CSRestUpdates(RID, UpdateDateTS) values (@RID, current_timestamp)
end
go
