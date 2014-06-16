if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobSelectUserOptInTxnLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobSelectUserOptInTxnLog]
go

create procedure [dbo].[JobSelectUserOptInTxnLog]
as
	
set nocount on
set transaction isolation level read uncommitted

declare	@ToBeRemovedMarker int  -- get the marker id just before midnight

select	@ToBeRemovedMarker = max(UserOptInTxnLogID)
from	UserOptInTxnLog
where	UpdatedDtUTC < cast(convert(char(8), getdate(), 112) as datetime)

select	UserOptInTxnLogID
		,CustID
		,CallerID
		,Spotlight
		,Insider
		,DinersChoice
		,NewHot
		,RestaurantWeek
		,Promotional
		,Product
		,MetroAreaID
		,MacroID
		,NeighborhoodID
		,UpdatedDtUTC
		,DBUser
		,Host
from	UserOptInTxnLog
where	UserOptInTxnLogID <= @ToBeRemovedMarker

GO

GRANT EXECUTE ON [JobSelectUserOptInTxnLog] TO ExecuteOnlyRole
GRANT EXECUTE ON [JobSelectUserOptInTxnLog] TO DTR_User

GO
