if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheDomain]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheDomain]
GO

CREATE Procedure dbo.DNCacheDomain
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

select 		d.*
from 		Domain d
inner join	DBUser db
on			db.DBUSer = User
and			IsNull(db.DomainID, d.DomainID) = d.DomainID
where		d.active = 1

GO

GRANT EXECUTE ON [DNCacheDomain] TO ExecuteOnlyRole

GO

