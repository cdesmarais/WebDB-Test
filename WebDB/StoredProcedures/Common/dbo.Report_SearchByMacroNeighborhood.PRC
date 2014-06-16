if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_SearchByMacroNeighborhood]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_SearchByMacroNeighborhood]
GO

CREATE PROCEDURE dbo.Report_SearchByMacroNeighborhood
(
	@reportDate datetime = null,
	@ui nvarchar(20)
)
AS

set transaction isolation level read uncommitted
set nocount on

If @reportDate is null select @reportDate = getdate()

Select t.MetroAreaID, t.MetroAreaName as MetroName
      ,Sum(Case when(datediff(day,mn.SearchLogDate,@reportDate) = 0 AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Yes
      ,Sum(Case when(datediff(month,mn.SearchLogDate,@reportDate) = 1 AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Prior
      ,Sum(Case when(datediff(day,mn.SearchLogDate,@reportDate) between 0 and 6 AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Week
      ,Sum(Case when(datediff(month,mn.SearchLogDate,@reportDate) = 0 AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Month
      ,Sum(Case when(datediff(year,mn.SearchLogDate,@reportDate) = 0 AND datediff(day,mn.SearchLogDate,@reportDate) >= 0 AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Year
      ,Sum(Case when(datediff(day,mn.SearchLogDate,@reportDate) = 0 AND mn.FoodType Is Not Null AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Yes_IndFood
      ,Sum(Case when(datediff(month,mn.SearchLogDate,@reportDate) = 0 AND mn.FoodType Is Not Null AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Prior_IndFood
      ,Sum(Case when(datediff(day,mn.SearchLogDate,@reportDate) between 0 and 6 AND mn.FoodType Is Not Null AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Week_IndFood
      ,Sum(Case when(datediff(month,mn.SearchLogDate,@reportDate) = 1 AND mn.FoodType Is Not Null AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Month_IndFood
      ,Sum(Case when(datediff(year,mn.SearchLogDate,@reportDate) = 0 AND datediff(day,mn.SearchLogDate,@reportDate) >= 0 AND mn.FoodType Is Not Null AND mn.SearchMetroAreaID <> 1) then 1 else 0 end) As Macro_Year_IndFood
      ,Sum(Case when(datediff(day,mn.SearchLogDate,@reportDate) = 0 AND mn.PriceRange <> '6' AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Yes_IndPrice
      ,Sum(Case when(datediff(month,mn.SearchLogDate,@reportDate) = 1 AND mn.PriceRange <> '6' AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Prior_IndPrice
      ,Sum(Case when(datediff(day,mn.SearchLogDate,@reportDate) between 0 and 6 AND mn.PriceRange <> '6' AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Week_IndPrice
      ,Sum(Case when(datediff(month,mn.SearchLogDate,@reportDate) = 0 AND mn.PriceRange <> '6' AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Month_IndPrice
      ,Sum(Case when(datediff(year,mn.SearchLogDate,@reportDate) = 0 AND datediff(day,mn.SearchLogDate,@reportDate) >= 0 AND mn.PriceRange <> '6' AND mn.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Year_IndPrice

From  MetroAreaVW t
left join SearchByMacroNeighborhood mn 
on mn.SearchMetroAreaID = t.MetroAreaID

Group By t.MetroAreaID, t.MetroAreaName
Order by t.MetroAreaName

GO


GRANT EXECUTE ON [Report_SearchByMacroNeighborhood] TO ExecuteOnlyRole

GO
