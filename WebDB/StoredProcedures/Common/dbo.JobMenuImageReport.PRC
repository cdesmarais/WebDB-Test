if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobMenuImageReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobMenuImageReport]
GO

CREATE PROCEDURE dbo.JobMenuImageReport

AS

--******************************
--** This report pulls the following 5 columns from webdb
--** RID, Rname, MenuURL, Show Image
--******************************
select		RVW.RID, 
			RName, 
			MenuURL, 
			coalesce(RI.ShowImage, 0) ShowImage,
			(case when RestStateID =1 then 1 else 0 end) Active
from		restaurantVW RVW
left join	restaurantImage RI
on			RVW.RID =RI.RID
group by	RVW.RID, 
			RName, 
			MenuURL, 
			RI.ShowImage, 
			RVW.RestStateID


GO
GRANT EXECUTE ON [JobMenuImageReport] TO ExecuteOnlyRole

GO
