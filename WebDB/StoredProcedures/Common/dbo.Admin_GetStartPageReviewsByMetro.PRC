if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetStartPageReviewsByMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetStartPageReviewsByMetro]
GO

CREATE Procedure dbo.Admin_GetStartPageReviewsByMetro  
(  
 @MetroAreaID int  
)  
  
As  
  
set transaction isolation level read uncommitted  
set nocount on  

Declare @CurrentDate datetime
set @CurrentDate = dbo.fGetDatePart(GETDATE())

select	MetroAreaID,  
		MacroID,  
		RID,  
		RName,  
		ResID as ReservationID,     
		VIP,  
		CustID,  
		CallerID,  
		OverallRating,  
		Comments,  
		ResponseDateUTC,  
		Suppressed,  
		SuppressedDate    
from    StartPageReviewsVW  
where   MetroAreaID = @MetroAreaID
and		(SuppressedDate is null OR SuppressedDate >= @CurrentDate)  

GO

GRANT EXECUTE ON [Admin_GetStartPageReviewsByMetro] TO ExecuteOnlyRole

GO