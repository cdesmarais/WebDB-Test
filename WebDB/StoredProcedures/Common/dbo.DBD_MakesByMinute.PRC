
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_MakesByMinute]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_MakesByMinute]
GO




CREATE PROCEDURE dbo.DBD_MakesByMinute
  
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select count(resid) as Resos, sum(PartySize) as Covers, datediff(mi,DateMade,getdate()) as DateMade
from reservation 
where datediff(mi,DateMade,getdate()) < 60 and rstateid = 1

group by datediff(mi,DateMade,getdate())
order by datediff(mi,DateMade,getdate()) desc

GO


GRANT EXECUTE ON [DBD_MakesByMinute] TO ExecuteOnlyRole

GO
