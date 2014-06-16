if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateRestStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateRestStatus]
GO



CREATE PROCEDURE dbo.DNUpdateRestStatus
(
	@RID int,
	@theState int
)
AS
--******************************************
--** Set the Restaurant Status to the desired state
--** Only performs acction if the restaurant was not already in desired state
--** If update was performed then creates a log entry
--** Returns the rowcount of the affected rows. 0 indicates no action taken
--******************************************

declare @rCount int
-- update the restaurant state (only perforemd if restaurant is not already in that state)
-- AND
-- if the new state is FRN (16) then only move to FRN *IF* the current state is ACTIVE (1)
-- otherwise per TT28048 we can incorrectly move a restuarant eventually back to ACTIVE when 
-- the cached state is active but the actual state is not active (eg client grace)
if @theState != 16
begin
	update	restaurant 
	set		reststateid= @theState 
	where	rid = @RID
	and		reststateid != @theState 
end
else
begin
	update	restaurant 
	set		reststateid= @theState 
	where	rid = @RID
	and		reststateid != @theState
	and  	reststateid = 1
	and		Allotment <> 1 -- ** Never allow Allotment to go FRN (there is no autorecovery)
end

set @rCount = @@ROWCOUNT


if @rCount > 0
begin	
	-- ** If a state change has occured indicted by the @@ROWCOUNT > 1 then create a log entry for it
	declare @Origin nvarchar(200) 
	set @Origin  = 'Aggregator(Auto): ' + SUBSTRING(HOST_NAME(), 1, 100)
	EXEC dbo.Admin_AuditRestStatusChg @RID, @Origin, @theState
end


-- ** Return the number of rows affected
select @rCount as RowsAffected


GO
GRANT EXECUTE ON [DNUpdateRestStatus] TO ExecuteOnlyRole

GO
