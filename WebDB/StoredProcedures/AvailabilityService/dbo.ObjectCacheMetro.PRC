if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ObjectCacheMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ObjectCacheMetro]
GO

create procedure dbo.ObjectCacheMetro
as
set nocount on
set transaction isolation level read uncommitted

SELECT  
			m.MetroAreaID,
			[TimeZoneOffset] = coalesce(t.ServerToLocalOffset, 0),
			m.CountryID
FROM		MetroArea m
INNER JOIN	TimeZoneVW t 
ON			(t.TZID = m.TZID) 
WHERE		(m.Active = 1 OR m.MetroAreaID = 1)

go


grant execute on [ObjectCacheMetro] to ExecuteOnlyRole

GO

