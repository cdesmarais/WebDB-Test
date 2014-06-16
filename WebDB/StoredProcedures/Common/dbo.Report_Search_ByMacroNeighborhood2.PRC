if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Search_ByMacroNeighborhood2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Search_ByMacroNeighborhood2]
GO




CREATE Procedure dbo.Report_Search_ByMacroNeighborhood2
(
	@reportDate datetime = null,
	@ui nvarchar(20)
)
AS

set transaction isolation level read uncommitted
set nocount on
if @reportDate is null select @reportDate = getdate()

Select t.metroareaid,t.name as metro_name
      ,Sum(Case when(datediff(day,mn.Search_Log_Date,@reportDate) = 0 AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Yes

      ,Sum(Case when(datediff(month,mn.Search_Log_Date,@reportDate) = 1 AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Prior

      ,Sum(Case when(datediff(day,mn.Search_Log_Date,@reportDate) between 0 and 6 AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Week
--      ,Sum(Case when(datediff(month,mn.Search_Log_Date,@reportDate) = 0 AND datediff(day,mn.Search_Log_Date,@reportDate) >= 0 AND mn.Search_metroareaid <> 1) then 1 else 0 end) As Macro_Month
      ,Sum(Case when(datediff(month,mn.Search_Log_Date,@reportDate) = 0 AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Month

      ,Sum(Case when(datediff(year,mn.Search_Log_Date,@reportDate) = 0 AND datediff(day,mn.Search_Log_Date,@reportDate) >= 0 AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Year
      ,Sum(Case when(datediff(day,mn.Search_Log_Date,@reportDate) = 0 AND mn.Food_Type Is Not Null AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Yes_IndFood
--      ,Sum(Case when(datediff(month,mn.Search_Log_Date,@reportDate) = 0 AND datediff(day,mn.Search_Log_Date,@reportDate) >= 0 AND mn.Food_Type Is Not Null AND mn.Search_metroareaid <> 1) then 1 else 0 end) As Macro_Prior_IndFood
      ,Sum(Case when(datediff(month,mn.Search_Log_Date,@reportDate) = 0 AND mn.Food_Type Is Not Null AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Prior_IndFood

      ,Sum(Case when(datediff(day,mn.Search_Log_Date,@reportDate) between 0 and 6 AND mn.Food_Type Is Not Null AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Week_IndFood
--      ,Sum(Case when(datediff(month,mn.Search_Log_Date,@reportDate) = 1 AND datediff(day,mn.Search_Log_Date,@reportDate) >= 0 AND mn.Food_Type Is Not Null AND mn.Search_metroareaid <> 1) then 1 else 0 end) As Macro_Month_IndFood
      ,Sum(Case when(datediff(month,mn.Search_Log_Date,@reportDate) = 1 AND mn.Food_Type Is Not Null AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Month_IndFood

      ,Sum(Case when(datediff(year,mn.Search_Log_Date,@reportDate) = 0 AND datediff(day,mn.Search_Log_Date,@reportDate) >= 0 AND mn.Food_Type Is Not Null AND mn.Search_metroareaid <> 1) then 1 else 0 end) As Macro_Year_IndFood
      ,Sum(Case when(datediff(day,mn.Search_Log_Date,@reportDate) = 0 AND mn.Price_Range <> '6' AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Yes_IndPrice
--      ,Sum(Case when(datediff(month,mn.Search_Log_Date,@reportDate) = 1 AND datediff(day,mn.Search_Log_Date,@reportDate) >= 0 AND mn.Price_Range < 6 AND mn.Search_metroareaid <> 1) then 1 else 0 end) As Macro_Prior_IndPrice
      ,Sum(Case when(datediff(month,mn.Search_Log_Date,@reportDate) = 1 AND mn.Price_Range <> '6' AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Prior_IndPrice

      ,Sum(Case when(datediff(day,mn.Search_Log_Date,@reportDate) between 0 and 6 AND mn.Price_Range <> '6' AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Week_IndPrice
--      ,Sum(Case when(datediff(month,mn.Search_Log_Date,@reportDate) = 0 AND datediff(day,mn.Search_Log_Date,@reportDate) >= 0 AND mn.Price_Range < 6 AND mn.Search_metroareaid <> 1) then 1 else 0 end) As Macro_Month_IndPrice
      ,Sum(Case when(datediff(month,mn.Search_Log_Date,@reportDate) = 0 AND mn.Price_Range <> '6' AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Month_IndPrice

      ,Sum(Case when(datediff(year,mn.Search_Log_Date,@reportDate) = 0 AND datediff(day,mn.Search_Log_Date,@reportDate) >= 0 AND mn.Price_Range <> '6' AND mn.Search_metroareaid <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',',',' + @ui + ',') > 0) then 1 else 0 end) As Macro_Year_IndPrice
From Search_ByMacroNeighborhood mn
	inner join MetroArea t on mn.search_metroareaid = t.metroareaid 

--From  MetroArea t
--	left join Search_ByMacroNeighborhood mn on mn.search_metroareaid = t.metroareaid

Group By t.metroareaid,t.Name
Order by t.name



GO

GRANT EXECUTE ON [Report_Search_ByMacroNeighborhood2] TO ExecuteOnlyRole

GO
