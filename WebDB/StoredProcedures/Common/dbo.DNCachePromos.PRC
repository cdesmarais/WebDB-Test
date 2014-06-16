if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCachePromos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCachePromos]
GO

CREATE PROCEDURE dbo.DNCachePromos
 As

SET NOCOUNT ON
set transaction isolation level read uncommitted

select PromoID, code, points, startdate, enddate
from promos
where active = 1
and enddate > getdate() - 1



go

GRANT EXECUTE ON [DNCachePromos] TO ExecuteOnlyRole

GO
