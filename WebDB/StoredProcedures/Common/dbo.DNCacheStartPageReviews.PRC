if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheStartPageReviews]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheStartPageReviews]
GO

CREATE Procedure dbo.DNCacheStartPageReviews
As

set transaction isolation level read uncommitted
set nocount on
	
select		MetroAreaID,
			MacroID,
			RID,
			ResID as ReservationID,			
			VIP,
			CustID,
			CallerID,	
			OverallRating,
			Comments,
			ResponseDateUTC,
			ResDT,
			Suppressed		
from		StartPageReviewsVW
where		Suppressed != 1

GO

GRANT EXECUTE ON [DNCacheStartPageReviews] TO ExecuteOnlyRole

GO


