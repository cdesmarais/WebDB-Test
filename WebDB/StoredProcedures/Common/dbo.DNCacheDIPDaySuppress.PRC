if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheDIPDaySuppress]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheDIPDaySuppress]
GO

CREATE PROCEDURE dbo.DNCacheDIPDaySuppress
As

set nocount on
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--*******************************
--** Retrieve all Days in the future (go back one day to be safe -- this is to ensure that all local times are present)
--*******************************
select		i.rid, 
			i.SuppressedDate
from		IncentiveSuppressDay i
inner join	IncentiveRestaurantStatus irs 
on			irs.RID = i.RID 
and			irs.Active = 1
where		irs.IncStatusID = 1
and			i.active = 1
and			i.SuppressedDate > getdate() - 1


GO


GRANT EXECUTE ON [dbo].[DNCacheDIPDaySuppress] TO ExecuteOnlyRole

GO
