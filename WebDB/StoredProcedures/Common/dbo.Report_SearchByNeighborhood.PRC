if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_SearchByNeighborhood]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_SearchByNeighborhood]
GO



CREATE PROCEDURE dbo.Report_SearchByNeighborhood
(
	@reportDate datetime = null,
	@ui nvarchar(20)
)
AS

set transaction isolation level read uncommitted
set nocount on

If @reportDate is null select @reportDate = getdate()

Select t.MetroAreaID, t.MetroAreaName as MetroName
      ,Sum(Case when(datediff(day,n.SearchLogDate,@reportDate) = 0 AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Yes
      ,Sum(Case when(datediff(month,n.SearchLogDate,@reportDate) = 1 AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Prior
      ,Sum(Case when(datediff(day,n.SearchLogDate,@reportDate) between 0 and 6 AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Week
      ,Sum(Case when(datediff(month,n.SearchLogDate,@reportDate) = 0 AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Month
      ,Sum(Case when(datediff(year,n.SearchLogDate,@reportDate) = 0 AND datediff(day,n.SearchLogDate,@reportDate) >= 0 AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Year
      ,Sum(Case when(datediff(day,n.SearchLogDate,@reportDate) = 0 AND n.FoodType Is Not Null AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Yes_IndFood
      ,Sum(Case when(datediff(month,n.SearchLogDate,@reportDate) = 1 AND n.FoodType Is Not Null AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Prior_IndFood
      ,Sum(Case when(datediff(day,n.SearchLogDate,@reportDate) between 0 and 6 AND n.FoodType Is Not Null AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Week_IndFood
      ,Sum(Case when(datediff(month,n.SearchLogDate,@reportDate) = 0 AND n.FoodType Is Not Null AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Month_IndFood
      ,Sum(Case when(datediff(year,n.SearchLogDate,@reportDate) = 0 AND datediff(day,n.SearchLogDate,@reportDate) >= 0 AND n.FoodType Is Not Null AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Year_IndFood
      ,Sum(Case when(datediff(day,n.SearchLogDate,@reportDate) = 0 AND n.PriceRange <> '6' AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Yes_IndPrice
      ,Sum(Case when(datediff(month,n.SearchLogDate,@reportDate) = 1 AND n.PriceRange <> '6' AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Prior_IndPrice
      ,Sum(Case when(datediff(day,n.SearchLogDate,@reportDate) between 0 and 6 AND n.PriceRange <> '6' AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Week_IndPrice
      ,Sum(Case when(datediff(month,n.SearchLogDate,@reportDate) = 0 AND n.PriceRange <> '6' AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Month_IndPrice
      ,Sum(Case when(datediff(year,n.SearchLogDate,@reportDate) = 0 AND datediff(day,n.SearchLogDate,@reportDate) >= 0 AND n.PriceRange <> '6' AND n.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Neighborhood_Year_IndPrice

From  MetroAreaVW t
left join SearchByNeighborhood n on n.SearchMetroAreaID = t.MetroAreaID

Group By t.MetroAreaID
, t.MetroAreaName
Order by t.MetroAreaName

GO



GRANT EXECUTE ON [Report_SearchByNeighborhood] TO ExecuteOnlyRole

GO
