if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Search_ByRest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Search_ByRest]
GO

CREATE PROCEDURE dbo.Report_Search_ByRest
(
	@reportDate datetime = null,
	@ui nvarchar(3)
)
AS
set transaction isolation level read uncommitted
set nocount on


If @reportDate is null select @reportDate = getdate()

Select t.MetroAreaID, t.MetroAreaName as MetroName
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 0 And CHARINDEX(',',RID) = 0 AND br.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Single_Yes
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 1 And CHARINDEX(',',RID) = 0 AND br.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Single_Prior
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) between 0 and 6 And CHARINDEX(',',RID) = 0 AND br.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Single_Week
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 0 AND CHARINDEX(',',RID) = 0 AND br.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Single_Month
      ,Sum(Case when(datediff(year,br.SearchLogDate,@reportDate) = 0 AND datediff(day,br.SearchLogDate,@reportDate) >= 0 And CHARINDEX(',',RID) = 0 AND br.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Single_Year
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) = 0 And CHARINDEX(',',RID) > 0 AND br.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As multi_Yes
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 1 AND CHARINDEX(',',RID) > 0 AND br.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As multi_Prior
      ,Sum(Case when(datediff(day,br.SearchLogDate,@reportDate) between 0 and 6 And CHARINDEX(',',RID) > 0 AND br.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As multi_Week
      ,Sum(Case when(datediff(month,br.SearchLogDate,@reportDate) = 0 AND CHARINDEX(',',RID) > 0 AND br.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As multi_Month
      ,Sum(Case when(datediff(year,br.SearchLogDate,@reportDate) = 0 AND datediff(day,br.SearchLogDate,@reportDate) >= 0 And CHARINDEX(',',RID) > 0 AND br.SearchMetroAreaID <> 1 AND CHARINDEX(',' + CAST(UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As multi_Year
From		SearchByRestaurant br
left join	MetroAreaVW t 
on			br.SearchMetroAreaID = t.MetroAreaID
Group By	t.MetroAreaID, t.MetroAreaName
order by	t.MetroAreaName

GO


GRANT EXECUTE ON [Report_Search_ByRest] TO ExecuteOnlyRole

GO
