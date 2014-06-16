if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportTotalTimeSlot]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportTotalTimeSlot]
GO

CREATE PROCEDURE dbo.JobReportTotalTimeSlot
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	declare @startDT datetime
	declare @endDT datetime
	
	select @endDT = DATEADD(day, 0, convert(datetime, convert(varchar(8), getdate(), 112)))  
	select @startDT = dateadd(day, -7, @endDT)	

	Select convert(char(10), s.DateTS, 101) AS 'All Slots Displayed',
	CONVERT(VARCHAR(5),n.MetroAreaID) + ' | ' + CONVERT(VARCHAR(100),m.MetroAreaName) AS 'Metro',
	SUM(ISNULL(SlotsAvail,0)) AS 'Count'
	from		SearchStats s
	INNER JOIN	dbo.VWebDB_RestaurantVW r
	ON			s.RestaurantID = r.RID
	INNER JOIN	dbo.VWebDB_NeighborhoodVW n
	ON			r.NeighborhoodID = n.NeighborhoodID
	INNER JOIN	dbo.VWebDB_MetroAreaVW m	
	ON			m.MetroAreaID = n.MetroAreaID
	where		RestaurantID != -1 
	AND			s.DateTS BETWEEN @startDT AND @endDT
	GROUP BY	convert(char(10), s.DateTS, 101)
				,n.MetroAreaID
				,m.MetroAreaName
		
GRANT EXECUTE ON [JobReportTotalTimeSlot] TO ExecuteOnlyRole
GO

GRANT EXECUTE ON [JobReportTotalTimeSlot] TO DTR_User
GO


