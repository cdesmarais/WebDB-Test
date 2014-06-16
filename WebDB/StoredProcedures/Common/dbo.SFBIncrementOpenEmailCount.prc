if exists (select * from dbo.sysobjects where ID = object_id(N'[dbo].[SFBIncrementOpenEmailCount]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
drop procedure [dbo].[SFBIncrementOpenEmailCount]
go

-- updates the count of the number of times a Share Feedback Email was opened
-- returns 0 on success, -1 for error
create procedure dbo.SFBIncrementOpenEmailCount
(
	@ResID	int
)
as

	set nocount on

	declare  @error	int
			,@rc	int

	update	ecbr
	set		OpenEmailCount = OpenEmailCount + 1
	from	SFBEmailCountByReso	ecbr
	where	ResID = @ResID

	select @error = @@error, @rc = @@rowcount
	if @error != 0 or @rc != 1 goto ErrBlock

	return 0	-- successfully incremented the count

ErrBlock:
	return -1	-- error

go


grant execute on [SFBIncrementOpenEmailCount] to ExecuteOnlyRole
go
