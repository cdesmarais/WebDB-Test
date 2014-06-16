if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Search_SavedResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Search_SavedResos]
GO

CREATE PROCEDURE dbo.Report_Search_SavedResos
(
 @reportDate datetime = null
,@ui nvarchar(5)
 )
AS

set transaction isolation level read uncommitted
set nocount on

If @reportDate is null select @reportDate = getdate()

if @ui = '1,2,3' or @ui = '2,3'

BEGIN

Select	 t.MetroAreaID
	,t.MetroAreaName as MetroName
	,coalesce(ct.Resos_Yes,0) As res_yes
	,coalesce(ct.Resos_Prior,0) As res_prior
	,coalesce(ct.Resos_Week,0) As res_week
	,coalesce(ct.Resos_Month,0) As res_month
	,coalesce(ct.Resos_YTD,0) As res_ytd
from	 MetroAreaVW t
left join	(Select n.MetroAreaID
		,Sum(Case when(datediff(day,r.DateMade,getdate()) = 0) then 1 else 0 end) As Resos_Yes
		,Sum(Case when(datediff(month,r.DateMade,getdate()) = 1) then 1 else 0 end) As Resos_Prior
		,Sum(Case when(datediff(day,r.DateMade,getdate()) between 0 and 6) then 1 else 0 end) As Resos_Week
		,Sum(Case when(datediff(month,r.DateMade,getdate()) = 0) then 1 else 0 end) As Resos_Month
		,Sum(Case when(r.DateMade >= '2001-10-30 00:00:00') then 1 else 0 end) As Resos_YTD
		From Reservation r
		inner join Restaurant rest 
		on rest.RID = r.RID
		inner join Neighborhood n 
		on n.NeighborhoodID = rest.NeighborhoodID
		Where r.RStateID not in  (3,4,8,9,10)
		and n.MetroAreaID <> 1 
		and r.PartnerID = 1
		Group By n.MetroAreaID
		) as ct
on ct.MetroAreaID = t.MetroAreaID
order by t.MetroAreaName


END

else

BEGIN
Select	 t.MetroAreaID
	,t.MetroAreaName as MetroName
	,coalesce(ct.Resos_Yes,0) As res_yes
	,coalesce(ct.Resos_Prior,0) As res_prior
	,coalesce(ct.Resos_Week,0) As res_week
	,coalesce(ct.Resos_Month,0) As res_month
	,coalesce(ct.Resos_YTD,0) As res_ytd
	 from MetroAreaVW t
left join	(Select n.MetroAreaID
		,Sum(Case when(datediff(day,r.DateMade,@reportDate) = 0 AND CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Resos_Yes
		,Sum(Case when(datediff(month,r.DateMade,@reportDate) = 1 AND CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Resos_Prior
		,Sum(Case when(datediff(day,r.DateMade,@reportDate) between 0 and 6 AND CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Resos_Week
		,Sum(Case when(datediff(month,r.DateMade,@reportDate) = 0 AND CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Resos_Month
		,Sum(Case when(r.DateMade >= '2001-10-30 00:00:00' AND CHARINDEX(',' + CAST(ui.UIType AS nvarchar(500)) + ',', ',' + @ui + ',') > 0) then 1 else 0 end) As Resos_YTD
		From Reservation r
		inner join Restaurant rest 
		on rest.RID = r.RID
		inner join Neighborhood n 
		on n.NeighborhoodID = rest.NeighborhoodID
		inner join Reservation_UI ui 
		on  r.ResID = ui.ResID
		Where r.RStateID not in (3,4,8,9,10)
		and n.MetroAreaID <> 1
		Group By n.MetroAreaID
		) as ct 
on ct.MetroAreaID = t.MetroAreaID
order by t.MetroAreaName

END
 
GO


GRANT EXECUTE ON [Report_Search_SavedResos] TO ExecuteOnlyRole

GO
