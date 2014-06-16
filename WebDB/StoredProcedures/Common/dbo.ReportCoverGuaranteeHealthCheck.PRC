
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReportCoverGuaranteeHealthCheck]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReportCoverGuaranteeHealthCheck]
GO

CREATE PROCEDURE [dbo].[ReportCoverGuaranteeHealthCheck]  
AS  

/******************************************************************************  
Procedure generate Covers Guarantte HealhCheck Report.  
Note: Procedure modified to removed the Link Server Dependency by creating new table
GOD_RestCoversGuaranteeDetails. This new table data will be populated by PJR job.
******************************************************************************/  

Declare @month int, @year int  
Select @month = month(getdate())  
select @Year  = year(getdate())  
  
set transaction isolation level read uncommitted   
  
select  getdate() ReportDate,  
   metro.metroAreaName,  
   rest.rid,   
   rest.rname,  
   rs.rState,  
   IsNull(romsCover.CoversGuarantee, 0) CoversGuarantee,  
   ISNULL(res.SeatedReso, 0)SeatedReso,  
   ISNULL(res.SeatedCovers, 0)SeatedCovers,  
   ISNULL(res.PendingReso, 0)PendingReso,  
   ISNULL(res.PendingCovers, 0)PendingCovers  
from  restaurantVW rest  
left join (select rid,   
   sum(case when rstateID<>1   
   then 1 else 0 end)   seatedReso,  
   sum(case when rstateID <> 1  
    then coalesce(seatedsize,partysize) else 0 end) SeatedCovers,  
   sum(case when rstateID = 1  
    then 1 else 0 end) PendingReso,  
   sum(case when rstateID = 1  
    then coalesce(seatedsize,partysize) else 0 end) PendingCovers      
    from reservation  
    where rstateID in (1,2,5,6,7)  
             and month(shiftdate)=@month and year(shiftdate)=@Year  
   group by RID) res  
on   res.rid = rest.rid  
inner join neighborhoodAVW hood  
on   rest.neighborhoodID = hood.neighborhoodID  
and      rest.LanguageID = hood.LanguageID  
inner join metroareaAVW metro  
on   hood.metroareaID = metro.metroAreaID  
and      rest.LanguageID = metro.LanguageID  
inner join  RestaurantState RS  
on   rest.RestStateID = RS.RestStateID  
left join dbo.[GOD_RestCoversGuaranteeDetails] romsCover  
on   romsCover.rid = rest.rid  
where  metro.metroAreaID <>1 and metro.Active = 1  
and   rs.rState<> 'inactive'  
group by  
   rest.rid,   
   rest.rname,  
   metro.metroAreaName,  
   RS.Rstate,  
   IsNull(romsCover.CoversGuarantee, 0),  
   res.SeatedReso,  
   res.SeatedCovers,  
   res.PendingReso,  
   res.PendingCovers  
order by   
   metro.metroAreaName,  
   rest.rname  
  
GO

GRANT EXECUTE ON [ReportCoverGuaranteeHealthCheck] TO ExecuteOnlyRole
GO 

