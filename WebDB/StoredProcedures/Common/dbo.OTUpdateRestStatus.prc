--OTUpdateRestStatus <rid-list>
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTUpdateRestStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTUpdateRestStatus]
GO

-- Updates elements of the alert. All elements except the alertid can be null..
CREATE PROCEDURE dbo.OTUpdateRestStatus
(
	@ridList varchar(5000), --[EV: List of Int IDs]
	@theState int
)
AS

-- update the restaurant state value of the rid's that were sent in..
update	restaurant 
set		reststateid= @theState 
where	rid in (select id from fIDStrToTab(@ridList, ','))
and		reststateid != @theState 


--*******************
--** Cursor through RID list and create log entry	
--*******************
declare Rid_Cursor cursor LOCAL READ_ONLY FOR
	select id from fIDStrToTab(@ridList, ',')
declare @RID int

OPEN Rid_Cursor
FETCH NEXT FROM Rid_Cursor 
INTO @RID

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.Admin_AuditRestStatusChg @RID, 'Aggregator(Auto)', @theState
	
	FETCH NEXT FROM Rid_Cursor 
	INTO @RID

END


GO
GRANT EXECUTE ON [OTUpdateRestStatus] TO ExecuteOnlyRole

GO
