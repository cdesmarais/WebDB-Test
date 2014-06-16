if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_GetCount_UpandDown]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_GetCount_UpandDown]
GO

CREATE PROCEDURE dbo.Report_GetCount_UpandDown
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select sum(case when(datediff(minute,OTErb.LTC, getdate()) >5 and OTRaunt.allotment = 0) Then 1 Else 0 End) As Downcount
,count(OTRaunt.RID) As TotalCount
,sum(case when(OTRaunt.allotment = 1) Then 1 Else 0 End) As AllotmentCount
from restaurant OTRaunt
inner join lastTimeContacted OTErb 
on OTRaunt.RID = OTErb.RID
inner join neighborhood OTHood 
on OTRaunt.NeighborhoodID = OTHood.NeighborhoodID
where OTHood.MetroAreaID <> 1 
and (OTRaunt.RestStateID = 1 or OTRaunt.RestStateID = 7)

GO


GRANT EXECUTE ON [Report_GetCount_UpandDown] TO ExecuteOnlyRole

GO
