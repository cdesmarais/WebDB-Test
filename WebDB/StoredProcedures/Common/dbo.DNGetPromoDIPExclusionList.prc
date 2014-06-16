if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetPromoDIPExclusionList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetPromoDIPExclusionList]
GO



-- Returns list of exclusions for all active promos
CREATE PROCEDURE dbo.DNGetPromoDIPExclusionList
AS
SET NOCOUNT ON
set transaction isolation level read uncommitted  


  select   n.MetroAreaID,p.SuppressDIP,p.EventStartDate,p.EventEndDate,p.SelectionDate,e.*   
 from PromoDIPSupressExclusion e     
 inner join PromoPages p on p.PromoID = e.PromoID  
 inner join Restaurant r on r.RID = e.RID   
 inner join Neighborhood n on n.NeighborhoodID = r.NeighborhoodID  
 inner join MetroArea m on m.metroAreaID = n.MetroareaID
 inner join TimeZoneVW tz on tz.TZID = m.TZID  
 where p.active = 1 
 and  p.EndDate >= tz.currentLocalTime  

GO

GRANT EXECUTE ON [DNGetPromoDIPExclusionList] TO ExecuteOnlyRole

GO
