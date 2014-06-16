if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_DIP_RestaurantRequest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_DIP_RestaurantRequest]
GO

CREATE PROCEDURE dbo.Report_DIP_RestaurantRequest

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

Select 
	rtReq.RequestName as [Restaurant Name]
	,City
	,State
	,ma.MetroAreaName as [User Metro]	
From		DIPRestaurantRequest rtReq
INNER JOIN	MetroAreaVW ma 
ON			rtReq.MetroID = ma.MetroAreaID
Where		rtReq.Sent = 0

GO


GRANT EXECUTE ON [Report_DIP_RestaurantRequest] TO ExecuteOnlyRole
GO





