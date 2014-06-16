
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminJustAddedNightlyJob]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminJustAddedNightlyJob]
GO
  
CREATE PROCEDURE [dbo].[AdminJustAddedNightlyJob]  
  
AS 
/******************************************************************************  
Procedure update just added list.  
Note: Procedure modified to removed the Link Server Dependency by creating new table
GOD_RestInstallDateDetails. This new table data will be populated from ROMS by PJR job.
******************************************************************************/   
 
--get data from roms and add to restauarantjustadded table  
update restaurantjustadded set dateadded = startdate, dateremoved = startdate + displaydays  
from restaurantjustadded rja  
inner join [dbo].[GOD_RestInstallDateDetails] result
on   result.rid = cast (rja.rid as nvarchar(10))  
inner join restaurant r on rja.rid = r.rid  
inner join neighborhood n on r.neighborhoodid = n.neighborhoodid  
inner join metroarea m on n.metroareaid = m.metroareaid  
where overridedate is null  
and dateadded is null  
  
  
--if day is blocked move out the dateadded one day  
update restaurantjustadded set dateadded = getdate() + 1  
from restaurantjustadded  
inner join blockedday on restaurantjustadded.rid = blockedday.rid  
where datediff(dd, dateadded, getdate()) >= 0 and  
 datediff(dd, blockeddate, getdate()) = 0 and   
 datediff(dd,restaurantjustadded.dateremoved, getdate()) < 0 and  
 justadded = 0  
  
  
--mark as just added so webpage will pick up     
update restaurantjustadded set justadded = 1,DateAdded = getdate()  
where justadded = 0 and  
 datediff(day,DateAdded,getdate()) >= 0 and  
 isnull(dateremoved,getdate()) > getdate()  
  
  
  
GO

GRANT EXECUTE ON [AdminJustAddedNightlyJob] TO ExecuteOnlyRole
GO 

