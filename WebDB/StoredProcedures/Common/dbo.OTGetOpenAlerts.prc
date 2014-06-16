if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTGetOpenAlerts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTGetOpenAlerts]
GO



CREATE PROCEDURE dbo.OTGetOpenAlerts
AS
-- get all Open Alerts..
select t.tier, p.alerttypedesc,a.*,t.tiernotificationlist,t.escalationthreshold,t.AlertIntervalMins 
from otalerts a,otalerttiers t,otalerttype p
where a.status <> 2 and a.tierid = t.alertTierID and p.alerttypeid=a.alerttypeid
order by a.alertcreatedatets asc

GO


GRANT EXECUTE ON [OTGetOpenAlerts] TO ExecuteOnlyRole

GO
