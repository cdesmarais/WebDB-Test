if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_ListActive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_ListActive]
GO


CREATE Procedure dbo.Restaurant_ListActive
As
--****************************************
--** EV: 09/23/04: Added IPAddress and Port, to select statement 
--**     used for improved performance of web site when data is cached
--****************************************
SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT     r.RID           AS RestaurantID
 		, (case when (charindex(':',serverIP) > 0)
			then substring(serverIP, 1, charindex(':',er.serverIP)-1) 
			else ''
			end) as IPAddress
		, (case when (charindex(':',serverIP) > 0)
			then cast(substring(serverIP, charindex(':',er.serverIP)+1, 10) as int)
			else -1
			end) as Port
          ,er.ServerIP           AS NetAddress
          ,er.serverPwd     AS Password
          ,ltc.LTC AS LastTimeContacted
FROM       Restaurant r
INNER JOIN ERBRestaurant er
ON         r.RID = er.RID
INNER JOIN LastTimeContacted ltc
ON		   r.RID = ltc.RID
WHERE     (r.RestStateID = 1) 
and        r.Allotment          <> 1
and        r.Ping                = 1
-- akash: filter restaurants based on product, only ERB,ERB-ParityListener and OT4.0 will be reverse pinged.
-- this takes care of NOT reverse pinging 4.5+/4.1/2.6 ERB's
and 	   er.ProductID IN (1,6,7)
option (keepfixed plan) --brendan: added to stop recompiles.  heavy activity on ERBRestaurant forces the recompile here.

GO

GRANT EXECUTE ON [Restaurant_ListActive] TO ExecuteOnlyRole

GO
