if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Weekly_RestaurantRequest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Weekly_RestaurantRequest]
GO

CREATE PROCEDURE dbo.Report_Weekly_RestaurantRequest

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

Select 
	rtReq.RequestName as [Restaurant Name]
	,City,State,ma.MetroAreaName as [User Metro]
	,FName as [User First],LName as [User Last]
	,Comments as Comment,
	(case when(ShareComments = 1) then 'Can Share' else 'Can''t Share' end) as [Can/Can't Share?]
From		RestaurantRequest rtReq
INNER JOIN	MetroAreaVW ma 
ON			rtReq.MetroID = ma.MetroAreaID
Where		rtReq.Sent = 0


GO


GRANT EXECUTE ON [Report_Weekly_RestaurantRequest] TO ExecuteOnlyRole

GO
