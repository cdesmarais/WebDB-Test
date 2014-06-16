if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Search_UsersByRest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Search_UsersByRest]
GO

CREATE PROCEDURE dbo.Report_Search_UsersByRest
(
	@reportDate datetime = null
)
AS
set transaction isolation level read uncommitted
set nocount on

If @reportDate is null select @reportDate = getdate()


Select t.MetroAreaID as metro_area_id
, t.MetroAreaName as MetroName

--users that searched a SINGLE Restaurant without logging in first
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 0
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As Single_Yes_Non
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 1
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As Single_Prior_Non
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) between 0 and 6
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As Single_Week_Non
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As Single_Month_Non
      ,Sum(Case when(datediff(year,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As Single_Year_Non

--NON ACTIVE users that searched a SINGLE Restaurant while logged in
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 0
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As Single_Yes_Log
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 1
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As Single_Prior_Log
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) between 0 and 6
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As Single_Week_Log
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As Single_Month_Log
      ,Sum(Case when(datediff(year,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As Single_YTD_Log
      
--ACTIVE users that searched a SINGLE Restaurant while logged in
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 0
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As Single_Yes_Act
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 1
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As Single_Prior_Act
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) between 0 and 6
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As Single_Week_Act

      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As Single_Month_Act
      ,Sum(Case when(datediff(year,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 0
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As Single_YTD_Act

--users that searched MULTIPLE RestaurantS without logging in first
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 0
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As multi_Yes_Non
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 1
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As multi_Prior_Non
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) between 0 and 6
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As multi_Week_Non
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As multi_Month_Non
      ,Sum(Case when(datediff(year,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is null and br.CallerID is null)) then 1 else 0 end) As multi_Year_Non

--NON-ACTIVE users that searched MULTIPLE RestaurantS while logged in
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 0
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As multi_Yes_Log
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 1
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As multi_Prior_Log
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) between 0 and 6
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As multi_Week_Log
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As multi_Month_Log
      ,Sum(Case when(datediff(year,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 0) then 1 else 0 end) As multi_Year_Log

--ACTIVE users that searched MULTIPLE RestaurantS while logged in
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 0
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As multi_Yes_Act
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 1
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As multi_Prior_Act
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) between 0 and 6
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As multi_Week_Act
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As multi_Month_Act
      ,Sum(Case when(datediff(year,br.SearchLogDate,@reportDate) = 0
	AND datediff(day,br.SearchLogDate,@reportDate) >= 0
	AND MultiSearch = 1
	AND br.SearchMetroAreaID <> 1
	AND (br.CustID is not null or br.CallerID is not null)
	AND br.ActiveUser = 1) then 1 else 0 end) As multi_Year_Act

From MetroAreaVW t
	inner join SearchByRestaurant br on br.SearchMetroAreaID = t.MetroAreaID
where t.Active = 1
Group By t.MetroAreaID, t.MetroAreaName
order by t.MetroAreaName
 
GO


GRANT EXECUTE ON [Report_Search_UsersByRest] TO ExecuteOnlyRole

GO
