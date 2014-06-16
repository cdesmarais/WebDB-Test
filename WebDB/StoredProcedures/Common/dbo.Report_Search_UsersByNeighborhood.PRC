if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Search_UsersByNeighborhood]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Search_UsersByNeighborhood]
GO

CREATE PROCEDURE dbo.Report_Search_UsersByNeighborhood
(
	@reportDate datetime = null
)
AS
set transaction isolation level read uncommitted
set nocount on

If @reportDate is null select @reportDate = getdate()


Select t.MetroAreaID as metro_area_id, t.MetroAreaName as MetroName

--users that searched a Neighborhood without logging in first
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As Neigh_Yes_Non
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As Neigh_Prior_Non
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) between 0 and 6
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As Neigh_Week_Non
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As Neigh_Month_Non
      ,Sum(Case when(datediff(year,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As Neigh_Year_Non

--NON ACTIVE users that searched a Neighborhood while logged in
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As Neigh_Yes_Log
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As Neigh_Prior_Log
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) between 0 and 6
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As Neigh_Week_Log
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As Neigh_Month_Log
      ,Sum(Case when(datediff(year,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As Neigh_YTD_Log
      
--ACTIVE users that searched a Neighborhood while logged in
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As Neigh_Yes_Act
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As Neigh_Prior_Act
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) between 0 and 6
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As Neigh_Week_Act
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As Neigh_Month_Act
      ,Sum(Case when(datediff(year,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As Neigh_YTD_Act

From MetroAreaVW t
	inner join SearchByNeighborhood br on br.SearchMetroAreaID = t.MetroAreaID
where t.Active = 1
Group By t.MetroAreaID, t.MetroAreaName
order by t.MetroAreaName

GO


GRANT EXECUTE ON [Report_Search_UsersByNeighborhood] TO ExecuteOnlyRole

GO
