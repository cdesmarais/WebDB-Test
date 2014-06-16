if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobExportTop10RestaurantList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobExportTop10RestaurantList]
GO


create  Procedure [dbo].[JobExportTop10RestaurantList]
AS

-- TT# 19355
-- The procedure export the weekly Top 10 restaurant booked per metro by users on our website to an Excel report
-- Report is being scheduled on Monday morning each week through a SQL DTS job

select	CONVERT(VARCHAR(10), getdate(), 101) ReportDate, 
		MA.MetroAreaName, 
		RTL.Rank, 
		R.RName,		
		R.RID 
from 
			RestaurantTopList RTL
inner join	RestaurantVW R
on			RTL.RID =R.RID
inner join	Neighborhood N
on			R.NeighborhoodID = N.NeighborhoodID
inner join	MetroAreaAVW MA
on			N.MetroAreaID = MA.MetroAreaID
and			MA.LanguageID = R.LanguageID
order by 
	MetroAreaName, 
	RTL.Rank 

GO


GRANT EXECUTE ON [JobExportTop10RestaurantList] TO ExecuteOnlyRole

GO

