if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobDeleteUserOptInTxnLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobDeleteUserOptInTxnLog]
go

create procedure [dbo].[JobDeleteUserOptInTxnLog]
as
	
set nocount on
set transaction isolation level read uncommitted

declare	@ToBeRemovedMarker int  -- get the marker id just before midnight

select	@ToBeRemovedMarker = max(UserOptInTxnLogID)
from	UserOptInTxnLog
where	UpdatedDtUTC < cast(convert(char(8), getdate(), 112) as datetime)

delete 	from UserOptInTxnLog
where	UserOptInTxnLogID <= @ToBeRemovedMarker


GO

GRANT EXECUTE ON [JobDeleteUserOptInTxnLog] TO ExecuteOnlyRole
GRANT EXECUTE ON [JobDeleteUserOptInTxnLog] TO DTR_User

GO
